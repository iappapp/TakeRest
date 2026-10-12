import SwiftUI
import AppKit

@main
struct TakeRestApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        Window("", id: "main") {
            MainRootView()
                .environmentObject(RestEngine.shared)
                .environmentObject(L10n.shared)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 900, height: 640)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(RestEngine.shared)
                .environmentObject(L10n.shared)
        } label: {
            MenuBarLabel()
                .environmentObject(RestEngine.shared)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        Notify.requestAuth()
        RestEngine.shared.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        RestEngine.shared.stop()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            sender.windows.first(where: { $0.identifier?.rawValue == "main" || $0.canBecomeMain })?.makeKeyAndOrderFront(nil)
        }
        return true
    }
}

struct MainRootView: View {
    @EnvironmentObject private var engine: RestEngine
    @EnvironmentObject private var l10n: L10n

    var body: some View {
        VStack(spacing: 0) {
            NavPill()
                .padding(.top, 10)
            Group {
                switch engine.tab {
                case .home: HomeView()
                case .stats: StatsView()
                case .settings: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Theme.bg)
        .frame(minWidth: 720, minHeight: 560)
    }
}

struct NavPill: View {
    @EnvironmentObject private var engine: RestEngine
    @EnvironmentObject private var l10n: L10n

    var body: some View {
        HStack(spacing: 2) {
            item(.home, "nav.home")
            item(.stats, "nav.stats")
            item(.settings, "nav.settings")
        }
        .padding(3)
        .background(Capsule().fill(Theme.pill))
        .overlay(Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1))
    }

    private func item(_ tab: Tab, _ key: String) -> some View {
        Button {
            engine.tab = tab
        } label: {
            Text(l10n.t(key))
                .font(.system(size: 13))
                .foregroundStyle(engine.tab == tab ? Theme.brown : Color.primary.opacity(0.75))
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background {
                    if engine.tab == tab {
                        Capsule().fill(Theme.bg)
                            .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

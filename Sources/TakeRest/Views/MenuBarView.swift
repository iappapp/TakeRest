import SwiftUI
import AppKit

struct MenuBarLabel: View {
    @EnvironmentObject private var engine: RestEngine

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: engine.preAlert ? "bell.badge.fill" : "desktopcomputer")
            Text(Fmt.clock(engine.remaining)).monospacedDigit()
        }
    }
}

struct MenuBarView: View {
    @EnvironmentObject private var engine: RestEngine
    @EnvironmentObject private var l10n: L10n
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(engine.phase == .onBreak ? l10n.t("break.title") : l10n.t("home.next"))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.gray)
                Text(Fmt.clock(engine.remaining))
                    .font(.system(size: 34, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(Theme.brown)
                HStack(spacing: 8) {
                    if engine.phase == .onBreak {
                        chip(l10n.t("break.skip")) { engine.skipBreak() }
                        chip(l10n.t("break.snooze")) { engine.snoozeBreak() }
                    } else {
                        chip(engine.phase == .paused ? l10n.t("home.resume") : l10n.t("home.pause")) {
                            engine.togglePause()
                        }
                        chip(l10n.t("home.restNow")) { engine.restNow() }
                    }
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)

            Divider()

            VStack(spacing: 2) {
                row(l10n.t("menu.open")) { openApp(tab: .home) }
                row(l10n.t("nav.settings")) { openApp(tab: .settings) }
                row(l10n.t("menu.quit")) { NSApp.terminate(nil) }
            }
            .padding(6)
        }
        .frame(width: 260)
        .background(Theme.bg)
    }

    private func chip(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(Theme.brown)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Theme.pill))
        }
        .buttonStyle(.plain)
    }

    private func row(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(Theme.brown)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(RoundedRectangle(cornerRadius: 7).fill(Theme.pill.opacity(0.7)))
        }
        .buttonStyle(.plain)
    }

    private func openApp(tab: Tab) {
        engine.tab = tab
        openWindow(id: "main")
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

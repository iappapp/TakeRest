import SwiftUI
import AppKit

@MainActor
final class BreakWindowController {
    static let shared = BreakWindowController()

    private var window: NSWindow?

    func show() {
        guard window == nil else { return }
        guard let screen = NSScreen.main else { return }

        let w = NSWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
        w.isOpaque = true
        w.backgroundColor = NSColor(red: 0.969, green: 0.949, blue: 0.925, alpha: 1)
        w.level = .screenSaver
        w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        w.ignoresMouseEvents = false
        w.hasShadow = false
        w.contentView = NSHostingView(rootView: BreakView().environmentObject(RestEngine.shared).environmentObject(L10n.shared))
        w.setFrame(screen.frame, display: true)
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window = w
    }

    func hide() {
        window?.orderOut(nil)
        window = nil
    }
}

struct BreakView: View {
    @EnvironmentObject private var engine: RestEngine
    @EnvironmentObject private var l10n: L10n

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(l10n.t("break.title"))
                .font(.system(size: 15))
                .foregroundStyle(Theme.gray)

            ZStack {
                Circle().stroke(Theme.track, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: engine.progress)
                    .stroke(Theme.brown, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(Fmt.clock(engine.remaining))
                    .font(.system(size: 52, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(Theme.brown)
            }
            .frame(width: 260, height: 260)
            .padding(.top, 20)

            Text(l10n.t(engine.breakTipKey))
                .font(.system(size: 14))
                .foregroundStyle(Theme.brownSoft)
                .padding(.top, 26)

            Spacer()

            HStack(spacing: 14) {
                Button(l10n.t("break.snooze")) { engine.snoozeBreak() }
                    .buttonStyle(BreakButtonStyle())
                Button(l10n.t("break.skip")) { engine.skipBreak() }
                    .buttonStyle(BreakButtonStyle(primary: true))
            }
            .padding(.bottom, 90)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bg)
    }
}

private struct BreakButtonStyle: ButtonStyle {
    var primary = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(primary ? Color.white : Theme.brown)
            .padding(.horizontal, 26)
            .padding(.vertical, 12)
            .background(Capsule().fill(primary ? Theme.brown : Theme.pill))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

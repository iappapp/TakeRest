import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var engine: RestEngine
    @EnvironmentObject private var l10n: L10n

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Theme.track, lineWidth: 11)
                Circle()
                    .trim(from: 0, to: engine.phase == .onBreak ? 1 : engine.progress)
                    .stroke(
                        engine.phase == .working ? Theme.brownSoft : Theme.brown,
                        style: StrokeStyle(lineWidth: 11, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                MonitorIcon()
                    .fill(Theme.brownSoft.opacity(0.35))
                    .overlay(MonitorIcon().stroke(Theme.brown, lineWidth: 1.5))
                    .frame(width: 62, height: 54)
            }
            .frame(width: 170, height: 170)

            VStack(spacing: 8) {
                Text(l10n.t("home.rule", engine.settings.workMinutes, engine.settings.restMinutes))
                Text(l10n.t("home.today", todayRest.count, todayRest.minutes))
                Text(engine.phase == .onBreak ? l10n.t("break.title") : l10n.t("home.next"))
            }
            .font(.system(size: 12))
            .foregroundStyle(Theme.gray)
            .multilineTextAlignment(.center)
            .padding(.top, 26)

            Text(Fmt.clock(engine.remaining))
                .font(.system(size: 64, weight: .medium, design: .default))
                .monospacedDigit()
                .foregroundStyle(Theme.brown)
                .padding(.top, 14)

            HStack(spacing: 10) {
                if engine.phase != .onBreak {
                    pillButton(
                        title: engine.phase == .paused ? l10n.t("home.resume") : l10n.t("home.pause"),
                        systemImage: engine.phase == .paused ? "play.fill" : "pause.fill"
                    ) {
                        engine.togglePause()
                    }
                    pillButton(title: l10n.t("home.restNow")) {
                        engine.restNow()
                    }
                } else {
                    pillButton(title: l10n.t("break.skip")) { engine.skipBreak() }
                    pillButton(title: l10n.t("break.snooze")) { engine.snoozeBreak() }
                }
            }
            .padding(.top, 22)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var todayRest: (count: Int, minutes: Int) {
        _ = engine.statsVersion
        _ = engine.remaining
        return engine.store.restSummary(on: Date())
    }

    private func pillButton(title: String, systemImage: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage).font(.system(size: 10))
                }
                Text(title).font(.system(size: 13))
            }
            .foregroundStyle(Theme.brown)
            .padding(.horizontal, 18)
            .padding(.vertical, 9)
            .background(Capsule().fill(Theme.pill))
        }
        .buttonStyle(.plain)
    }
}

/// Simple display shape: rounded screen + neck + base, matching the PRD glyph.
struct MonitorIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let screen = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height * 0.68
        )
        p.addRoundedRect(in: screen, cornerSize: CGSize(width: 5, height: 5))
        let neckW = rect.width * 0.16
        let neckH = rect.height * 0.16
        p.addRect(CGRect(
            x: rect.midX - neckW / 2,
            y: screen.maxY,
            width: neckW,
            height: neckH
        ))
        let baseW = rect.width * 0.36
        let baseH = rect.height * 0.075
        p.addRoundedRect(in: CGRect(
            x: rect.midX - baseW / 2,
            y: screen.maxY + neckH,
            width: baseW,
            height: baseH
        ), cornerSize: CGSize(width: 2, height: 2))
        return p
    }
}


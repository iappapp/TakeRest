import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var engine: RestEngine
    @EnvironmentObject private var l10n: L10n

    private let days = 7

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            legend
                .padding(.horizontal, 24)
                .padding(.top, 18)

            TimelineAxis()
                .frame(height: 16)
                .padding(.horizontal, 110)
                .padding(.top, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    ForEach(visibleDays, id: \.self) { day in
                        dayRow(day)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var visibleDays: [Date] {
        _ = engine.statsVersion
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<days)
            .map { cal.date(byAdding: .day, value: -$0, to: today)! }
            .filter { day in
                if Calendar.current.isDateInToday(day) { return true }
                return engine.store.segments(on: day).contains { $0.kind != .off }
            }
    }

    private var legend: some View {
        HStack(spacing: 18) {
            legendItem(Theme.timelineUse, "stats.use")
            legendItem(Theme.brownSoft, "stats.rest")
            legendItem(Theme.timelineTrack, "stats.off")
        }
    }

    private func legendItem(_ color: Color, _ key: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(l10n.t(key)).font(.system(size: 11)).foregroundStyle(Theme.gray)
        }
    }

    private func dayRow(_ day: Date) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text(Fmt.dayLabel(day, code: l10n.code))
                .font(.system(size: 12))
                .foregroundStyle(.primary.opacity(0.8))
                .frame(width: 70, alignment: .leading)

            DayTimeline(segments: engine.store.segments(on: day), isToday: Calendar.current.isDateInToday(day))
                .frame(height: 20)
        }
    }
}

private struct TimelineAxis: View {
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach([0, 6, 12, 18, 24], id: \.self) { hour in
                    let frac = CGFloat(hour) / 24
                    Text(String(format: "%02d:00", hour))
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.gray)
                        .fixedSize()
                        .offset(x: min(max(geo.size.width * frac - 18, 0), max(geo.size.width - 36, 0)))
                }
            }
        }
    }
}

private struct DayTimeline: View {
    let segments: [Segment]
    let isToday: Bool

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Theme.timelineTrack)
                    .frame(width: w)

                ForEach(Array(segments.enumerated()), id: \.offset) { _, seg in
                    rect(for: seg, width: w)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
        }
    }

    private func rect(for seg: Segment, width w: CGFloat) -> some View {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: seg.start)
        let x0 = frac(seg.start, dayStart) * w
        let x1 = frac(seg.end, dayStart) * w
        return RoundedRectangle(cornerRadius: 3)
            .fill(color(for: seg.kind))
            .frame(width: max(x1 - x0, 1.5), height: 20)
            .offset(x: x0)
    }

    private func frac(_ date: Date, _ dayStart: Date) -> CGFloat {
        CGFloat(min(max(date.timeIntervalSince(dayStart), 0), 86_400) / 86_400)
    }

    private func color(for kind: Segment.Kind) -> Color {
        switch kind {
        case .use: return Theme.timelineUse
        case .rest: return Theme.brownSoft
        case .off: return Theme.timelineTrack
        }
    }
}

import Foundation

struct Segment: Codable, Equatable {
    enum Kind: String, Codable {
        case use   // 使用电脑
        case rest  // 休息
        case off   // 暂停 / 未计时
    }

    var kind: Kind
    var start: Date
    var end: Date
}

final class SegmentStore {
    static let shared = SegmentStore()

    private(set) var closed: [Segment] = []
    private var open: Segment?
    private let url: URL
    private let keepDays = 30

    var current: [Segment] {
        guard let open else { return closed }
        return closed + [open]
    }

    private init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TakeRest", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        url = dir.appendingPathComponent("segments.json")
        load()
        prune(now: Date())
    }

    func setKind(_ kind: Segment.Kind, at date: Date = Date()) {
        if let o = open, o.kind == kind {
            open?.end = date
            return
        }
        if var o = open {
            o.end = date
            closed.append(o)
        }
        open = Segment(kind: kind, start: date, end: date)
        save()
    }

    func closeOpen(at date: Date = Date()) {
        guard var o = open else { return }
        o.end = date
        closed.append(o)
        open = nil
        save()
    }

    func segments(on day: Date, now: Date = Date()) -> [Segment] {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: day)
        let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart)!
        return current.filter { $0.end > dayStart && $0.start < dayEnd }
    }

    func restSummary(on day: Date, now: Date = Date()) -> (count: Int, minutes: Int) {
        let rests = segments(on: day, now: now).filter { $0.kind == .rest }
        let total = rests.reduce(0.0) { $0 + max(0, $1.end.timeIntervalSince($1.start)) }
        let meaningful = rests.filter { $0.end.timeIntervalSince($0.start) >= 20 }.count
        return (meaningful, Int(total / 60))
    }

    private func load() {
        guard let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([Segment].self, from: data) else { return }
        closed = list
    }

    func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        guard let data = try? encoder.encode(current) else { return }
        try? data.write(to: url, options: .atomic)
    }

    private func prune(now: Date) {
        let cutoff = Calendar.current.date(byAdding: .day, value: -keepDays, to: now)!
        closed.removeAll { $0.end < cutoff }
    }
}

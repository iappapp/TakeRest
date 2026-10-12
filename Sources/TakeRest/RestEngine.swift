import SwiftUI
import Combine
import AppKit
import AudioToolbox
import ServiceManagement

enum Phase {
    case working
    case paused
    case onBreak
}

enum Tab: Hashable {
    case home, stats, settings
}

final class AppSettings: ObservableObject {
    private let d = UserDefaults.standard

    @Published var workMinutes: Int { didSet { d.set(workMinutes, forKey: "workMinutes") } }
    @Published var restMinutes: Int { didSet { d.set(restMinutes, forKey: "restMinutes") } }
    @Published var preNotifySeconds: Int { didSet { d.set(preNotifySeconds, forKey: "preNotifySeconds") } }
    @Published var soundOnRestEnd: Bool { didSet { d.set(soundOnRestEnd, forKey: "soundOnRestEnd") } }
    @Published var launchAtLogin: Bool {
        didSet {
            d.set(launchAtLogin, forKey: "launchAtLogin")
            applyLoginItem()
        }
    }

    init() {
        workMinutes = (d.object(forKey: "workMinutes") as? Int) ?? 40
        restMinutes = (d.object(forKey: "restMinutes") as? Int) ?? 5
        preNotifySeconds = (d.object(forKey: "preNotifySeconds") as? Int) ?? 30
        soundOnRestEnd = (d.object(forKey: "soundOnRestEnd") as? Bool) ?? true
        launchAtLogin = (d.object(forKey: "launchAtLogin") as? Bool) ?? (SMAppService.mainApp.status == .enabled)
    }

    private func applyLoginItem() {
        guard Bundle.main.bundleIdentifier != nil, !isXcodePreview else { return }
        do {
            if launchAtLogin {
                if SMAppService.mainApp.status != .enabled { try SMAppService.mainApp.register() }
            } else if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("TakeRest: login item failed: \(error)")
        }
    }

    private var isXcodePreview: Bool {
        Bundle.main.bundlePath.contains("DerivedData") || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

@MainActor
final class RestEngine: ObservableObject {
    static let shared = RestEngine()

    let settings = AppSettings()
    let store = SegmentStore.shared

    @Published var phase: Phase = .working
    @Published var remaining: Int
    @Published var cycleTotal: Int
    @Published var preAlert = false
    @Published var tab: Tab = .home
    @Published var breakTipKey: String = "tip.1"
    @Published var statsVersion = 0

    private var timer: Timer?
    private var saveCounter = 0
    private let idleLimitSeconds = 60.0

    private init() {
        let total = settings.workMinutes * 60
        cycleTotal = total
        remaining = total
    }

    var progress: Double {
        guard cycleTotal > 0 else { return 0 }
        return min(1, max(0, 1 - Double(remaining) / Double(cycleTotal)))
    }

    func start() {
        store.setKind(phaseKind())
        timer?.invalidate()
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        store.closeOpen()
    }

    // MARK: - Tick

    private func tick() {
        let idle = idleSeconds()

        switch phase {
        case .paused:
            store.setKind(.off)
        case .onBreak:
            store.setKind(.rest)
            remaining -= 1
            if remaining <= 0 {
                finishBreak(natural: true)
            }
        case .working:
            if idle >= idleLimitSeconds {
                store.setKind(.off)
            } else {
                store.setKind(.use)
                if remaining > 0 { remaining -= 1 }
                if settings.preNotifySeconds > 0, remaining == settings.preNotifySeconds, remaining > 0 {
                    preAlert = true
                    Sound.playAlert()
                    Notify.preBreak(seconds: settings.preNotifySeconds)
                }
                if remaining <= 0 {
                    startBreak()
                }
            }
        }

        if preAlert, phase == .working, remaining > settings.preNotifySeconds {
            preAlert = false
        }

        saveCounter += 1
        if saveCounter >= 30 {
            saveCounter = 0
            store.save()
            statsVersion += 1
        }
    }

    private func phaseKind() -> Segment.Kind {
        switch phase {
        case .onBreak: return .rest
        case .paused: return .off
        case .working: return .use
        }
    }

    private func idleSeconds() -> Double {
        let anyEvent = CGEventType(rawValue: 0xFFFFFFFF)!
        return CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: anyEvent)
    }

    // MARK: - Commands

    func togglePause() {
        if phase == .paused {
            phase = .working
            store.setKind(idleSeconds() >= idleLimitSeconds ? .off : .use)
        } else if phase == .working {
            phase = .paused
            store.setKind(.off)
        }
    }

    func restNow() {
        guard phase != .onBreak else { return }
        startBreak()
    }

    func startBreak() {
        phase = .onBreak
        remaining = settings.restMinutes * 60
        cycleTotal = remaining
        preAlert = false
        let tips = ["tip.1", "tip.2", "tip.3", "tip.4"]
        breakTipKey = tips.randomElement() ?? "tip.1"
        store.setKind(.rest)
        BreakWindowController.shared.show()
        Notify.breakStarted(minutes: settings.restMinutes)
    }

    func finishBreak(natural: Bool) {
        if phase == .onBreak {
            BreakWindowController.shared.hide()
            if natural && settings.soundOnRestEnd {
                Sound.playAlert()
            }
            if natural { Notify.breakEnded() }
            statsVersion += 1
        }
        phase = .working
        cycleTotal = settings.workMinutes * 60
        remaining = cycleTotal
        store.setKind(.use)
    }

    func skipBreak() {
        finishBreak(natural: false)
    }

    func snoozeBreak() {
        guard phase == .onBreak else { return }
        BreakWindowController.shared.hide()
        phase = .working
        cycleTotal = 5 * 60
        remaining = cycleTotal
        store.setKind(.use)
    }
}

enum Sound {
    static func playAlert() {
        AudioServicesPlaySystemSound(1005) // Glass
    }
}

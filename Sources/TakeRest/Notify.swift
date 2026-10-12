import Foundation
import UserNotifications

enum Notify {
    static func requestAuth() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if !granted { NSLog("TakeRest: notification permission denied") }
        }
    }

    static func post(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func preBreak(seconds: Int) {
        let l = L10n.shared
        post(title: l.t("notify.pre.title"), body: l.t("notify.pre.body", seconds))
    }

    static func breakStarted(minutes: Int) {
        let l = L10n.shared
        post(title: l.t("notify.start.title"), body: l.t("notify.start.body", minutes))
    }

    static func breakEnded() {
        let l = L10n.shared
        post(title: l.t("notify.end.title"), body: l.t("notify.end.body"))
    }
}

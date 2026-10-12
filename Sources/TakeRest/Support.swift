import SwiftUI
import Combine

enum AppLang: String, CaseIterable {
    case system, zh, zhHant, ja, en
}

final class L10n: ObservableObject {
    static let shared = L10n()

    @Published var setting: AppLang = .system {
        didSet {
            refresh()
            UserDefaults.standard.set(setting.rawValue, forKey: "appLang")
        }
    }
    private(set) var code = "zh"

    private init() {
        if let raw = UserDefaults.standard.string(forKey: "appLang"), let s = AppLang(rawValue: raw) {
            setting = s
        }
        refresh()
    }

    var isChinese: Bool { code == "zh" || code == "zhHant" }

    func refresh() {
        switch setting {
        case .zh: code = "zh"
        case .zhHant: code = "zhHant"
        case .ja: code = "ja"
        case .en: code = "en"
        case .system:
            let lang = Locale.preferredLanguages.first ?? "zh"
            if lang.hasPrefix("zh-Hant") || lang.hasPrefix("zh-TW") || lang.hasPrefix("zh-HK") || lang.hasPrefix("zh-MO") {
                code = "zhHant"
            } else if lang.hasPrefix("zh") {
                code = "zh"
            } else if lang.hasPrefix("ja") {
                code = "ja"
            } else {
                code = "en"
            }
        }
        objectWillChange.send()
    }

    func t(_ key: String) -> String {
        Self.table[code]?[key] ?? Self.table["zh"]?[key] ?? key
    }

    func t(_ key: String, _ n: Int) -> String {
        let raw = Self.table[code]?[key] ?? Self.table["zh"]?[key] ?? key
        return String(format: raw, n)
    }

    func t(_ key: String, _ a: Int, _ b: Int) -> String {
        let raw = Self.table[code]?[key] ?? Self.table["zh"]?[key] ?? key
        return String(format: raw, a, b)
    }

    static let table: [String: [String: String]] = [
        "zh": [
            "app.name": "小憩",
            "nav.home": "首页",
            "nav.stats": "统计",
            "nav.settings": "设置",
            "home.rule": "每使用电脑 %1$d 分钟，休息 %2$d 分钟",
            "home.today": "今日已休息 %d 次，共 %d 分钟",
            "home.next": "距离下次休息提醒",
            "home.pause": "暂停",
            "home.resume": "继续",
            "home.restNow": "立即休息",
            "stats.use": "使用电脑",
            "stats.rest": "休息",
            "stats.off": "暂停 / 未计时",
            "settings.timing": "计时",
            "settings.work": "使用电脑时长",
            "settings.rest": "休息时长",
            "settings.pre": "休息前提醒",
            "settings.general": "通用",
            "settings.login": "开机后自动打开 App",
            "settings.lang": "语言",
            "settings.lang.system": "跟随系统",
            "settings.lang.zh": "简体中文",
            "settings.lang.zhHant": "繁體中文",
            "settings.lang.ja": "日本語",
            "settings.lang.en": "English",
            "settings.sound": "休息结束时播放提示音",
            "settings.help": "帮助",
            "settings.guide": "使用说明",
            "settings.guide.btn": "查看使用说明",
            "settings.privacy": "隐私政策",
            "settings.privacy.btn": "查看隐私政策",
            "unit.minute": "分钟",
            "unit.second": "秒",
            "menu.open": "打开 APP",
            "menu.quit": "退出",
            "break.title": "休息时间",
            "break.hint": "距离下次休息提醒",
            "break.skip": "提前结束",
            "break.snooze": "稍后 5 分钟",
            "tip.1": "看看 6 米外的地方，放松眼睛",
            "tip.2": "站起来伸展一下肩颈和腰背",
            "tip.3": "喝口水，补充水分",
            "tip.4": "转动脚踝和手腕，活动关节",
            "guide.body": "小憩会在你连续使用电脑达到设定时长后，弹出全屏休息提醒；休息结束会播放提示音。\n\n闲置、锁屏或被暂停的时间不会计入使用时长，可在「统计」页查看每天的时间分布。\n\n可在「设置」中调整使用与休息时长、语言与开机自启。",
            "privacy.body": "小憩完全在本机运行：使用时长、休息记录等所有数据仅保存在你自己的电脑上，不会上传、不会收集任何个人信息，也没有网络请求。",
            "notify.pre.title": "马上要休息了",
            "notify.pre.body": "还有 %d 秒，准备收尾吧",
            "notify.start.title": "休息时间到了",
            "notify.start.body": "起来活动一下，休息 %d 分钟",
            "notify.end.title": "休息结束",
            "notify.end.body": "新的周期已开始，继续加油",
        ],
        "en": [
            "app.name": "TakeRest",
            "nav.home": "Home",
            "nav.stats": "Stats",
            "nav.settings": "Settings",
            "home.rule": "Rest %2$d min after every %1$d min at the computer",
            "home.today": "%1$d rests today, %2$d min total",
            "home.next": "Until next break reminder",
            "home.pause": "Pause",
            "home.resume": "Resume",
            "home.restNow": "Rest now",
            "stats.use": "Using",
            "stats.rest": "Rest",
            "stats.off": "Paused / untracked",
            "settings.timing": "Timing",
            "settings.work": "Screen time",
            "settings.rest": "Break length",
            "settings.pre": "Remind before break",
            "settings.general": "General",
            "settings.login": "Open at login",
            "settings.lang": "Language",
            "settings.lang.system": "System",
            "settings.lang.zh": "简体中文",
            "settings.lang.zhHant": "繁體中文",
            "settings.lang.ja": "日本語",
            "settings.lang.en": "English",
            "settings.sound": "Play sound when break ends",
            "settings.help": "Help",
            "settings.guide": "User guide",
            "settings.guide.btn": "View guide",
            "settings.privacy": "Privacy",
            "settings.privacy.btn": "View privacy",
            "unit.minute": "min",
            "unit.second": "sec",
            "menu.open": "Open App",
            "menu.quit": "Quit",
            "break.title": "Time to rest",
            "break.hint": "Until next break reminder",
            "break.skip": "End early",
            "break.snooze": "Snooze 5 min",
            "tip.1": "Look at something 6 meters away",
            "tip.2": "Stand up and stretch",
            "tip.3": "Drink some water",
            "tip.4": "Move your wrists and ankles",
            "guide.body": "TakeRest shows a full-screen break reminder once your continuous screen time reaches the configured length, and plays a sound when the break ends.\n\nIdle, locked or paused time is never counted. Check the Stats page for your daily timeline.\n\nDurations, language and login items live in Settings.",
            "privacy.body": "TakeRest runs entirely on your machine. Usage and break records stay local: nothing is uploaded, no personal data is collected, and the app makes no network requests.",
            "notify.pre.title": "Break soon",
            "notify.pre.body": "In %d seconds — start wrapping up",
            "notify.start.title": "Time for a break",
            "notify.start.body": "Stand up and rest for %d minutes",
            "notify.end.title": "Break over",
            "notify.end.body": "A new cycle has started",
        ],
        "zhHant": [
            "app.name": "小憩",
            "nav.home": "首頁",
            "nav.stats": "統計",
            "nav.settings": "設定",
            "home.rule": "每使用電腦 %1$d 分鐘，休息 %2$d 分鐘",
            "home.today": "今日已休息 %d 次，共 %d 分鐘",
            "home.next": "距離下次休息提醒",
            "home.pause": "暫停",
            "home.resume": "繼續",
            "home.restNow": "立即休息",
            "stats.use": "使用電腦",
            "stats.rest": "休息",
            "stats.off": "暫停 / 未計時",
            "settings.timing": "計時",
            "settings.work": "使用電腦時長",
            "settings.rest": "休息時長",
            "settings.pre": "休息前提醒",
            "settings.general": "通用",
            "settings.login": "開機後自動打開 App",
            "settings.lang": "語言",
            "settings.lang.system": "跟隨系統",
            "settings.lang.zh": "简体中文",
            "settings.lang.zhHant": "繁體中文",
            "settings.lang.ja": "日本語",
            "settings.lang.en": "English",
            "settings.sound": "休息結束時播放提示音",
            "settings.help": "幫助",
            "settings.guide": "使用說明",
            "settings.guide.btn": "查看使用說明",
            "settings.privacy": "隱私政策",
            "settings.privacy.btn": "查看隱私政策",
            "unit.minute": "分鐘",
            "unit.second": "秒",
            "menu.open": "打開 APP",
            "menu.quit": "退出",
            "break.title": "休息時間",
            "break.hint": "距離下次休息提醒",
            "break.skip": "提前結束",
            "break.snooze": "稍後 5 分鐘",
            "tip.1": "看看 6 米外的地方，放鬆眼睛",
            "tip.2": "站起來伸展一下肩頸和腰背",
            "tip.3": "喝口水，補充水分",
            "tip.4": "轉動腳踝和手腕，活動關節",
            "guide.body": "小憩會在你連續使用電腦達到設定時長後，彈出全螢幕休息提醒；休息結束會播放提示音。\n\n閒置、鎖屏或被暫停的時間不會計入使用時長，可在「統計」頁查看每天的時間分佈。\n\n可在「設定」中調整使用與休息時長、語言與開機自啟。",
            "privacy.body": "小憩完全在本機執行：使用時長、休息記錄等所有資料僅保存在你自己的電腦上，不會上傳、不會收集任何個人資料，也沒有網路請求。",
            "notify.pre.title": "馬上要休息了",
            "notify.pre.body": "還有 %d 秒，準備收尾吧",
            "notify.start.title": "休息時間到了",
            "notify.start.body": "起來活動一下，休息 %d 分鐘",
            "notify.end.title": "休息結束",
            "notify.end.body": "新的週期已開始，繼續加油",
        ],
        "ja": [
            "app.name": "小憩",
            "nav.home": "ホーム",
            "nav.stats": "統計",
            "nav.settings": "設定",
            "home.rule": "PC使用 %1$d 分ごとに %2$d 分休憩しましょう",
            "home.today": "今日は %d 回休憩、合計 %d 分",
            "home.next": "次の休憩通知まで",
            "home.pause": "一時停止",
            "home.resume": "再開",
            "home.restNow": "今すぐ休憩",
            "stats.use": "PC使用",
            "stats.rest": "休憩",
            "stats.off": "一時停止 / 未計測",
            "settings.timing": "タイマー",
            "settings.work": "PC使用時間",
            "settings.rest": "休憩時間",
            "settings.pre": "休憩前の通知",
            "settings.general": "一般",
            "settings.login": "ログイン時に自動起動",
            "settings.lang": "言語",
            "settings.lang.system": "システムに従う",
            "settings.lang.zh": "简体中文",
            "settings.lang.zhHant": "繁體中文",
            "settings.lang.ja": "日本語",
            "settings.lang.en": "English",
            "settings.sound": "休憩終了時に通知音を再生",
            "settings.help": "ヘルプ",
            "settings.guide": "使い方",
            "settings.guide.btn": "使い方を見る",
            "settings.privacy": "プライバシーポリシー",
            "settings.privacy.btn": "ポリシーを見る",
            "unit.minute": "分",
            "unit.second": "秒",
            "menu.open": "アプリを開く",
            "menu.quit": "終了",
            "break.title": "休憩時間",
            "break.hint": "次の休憩通知まで",
            "break.skip": "早めに終了",
            "break.snooze": "5分あとで",
            "tip.1": "6メートル先を見て目を休めましょう",
            "tip.2": "立って肩や首を伸ばしましょう",
            "tip.3": "水を一杯飲んで水分補給",
            "tip.4": "手首や足首を動かしましょう",
            "guide.body": "連続してPCを使用した時間が設定時間に達すると、全画面の休憩通知が表示され、休憩終了時に通知音が再生されます。\n\nアイドル、画面ロック、一時停止中は計測されません。1日の内訳は「統計」ページでご確認ください。\n\n時間・言語・ログイン時起動は「設定」で変更できます。",
            "privacy.body": "本アプリは完全に端末内で動作します。使用時間や休憩の記録はすべてお使いのコンピュータにのみ保存され、アップロードや個人情報の収集、通信は一切行いません。",
            "notify.pre.title": "もうすぐ休憩です",
            "notify.pre.body": "あと %d 秒、区切りをつけましょう",
            "notify.start.title": "休憩の時間です",
            "notify.start.body": "立って体を伸ばし、%d 分間休みましょう",
            "notify.end.title": "休憩終了",
            "notify.end.body": "新しいサイクルが始まりました",
        ],
    ]
}

enum Fmt {
    static func clock(_ seconds: Int) -> String {
        let s = max(0, seconds)
        return String(format: "%02d:%02d", s / 60, s % 60)
    }

    static func dayLabel(_ date: Date, code: String) -> String {
        let f = DateFormatter()
        switch code {
        case "en":
            f.locale = Locale(identifier: "en_US")
            f.dateFormat = "MMM d, EEEE"
        case "ja":
            f.locale = Locale(identifier: "ja_JP")
            f.dateFormat = "M月d日 EEEE"
        case "zhHant":
            f.locale = Locale(identifier: "zh_Hant")
            f.dateFormat = "M月d日 EEEE"
        default:
            f.locale = Locale(identifier: "zh_CN")
            f.dateFormat = "M月d日 EEEE"
        }
        return f.string(from: date)
    }
}

enum Theme {
    static let bg = Color(hex: 0xF7F2EC)
    static let brown = Color(hex: 0x6B4F3A)
    static let brownSoft = Color(hex: 0x8C6A4F)
    static let track = Color(hex: 0xE5D9C9)
    static let pill = Color(hex: 0xEDEAE4)
    static let gray = Color(hex: 0xA89E92)
    static let card = Color(hex: 0xF0ECE5)
    static let timelineTrack = Color(hex: 0xD8D8D8)
    static let timelineUse = Color(hex: 0xA9BAC9)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

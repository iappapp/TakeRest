# 小憩 TakeRest

一款 macOS 定时休息提醒应用:连续使用电脑达到设定时长后,弹出全屏休息遮罩,帮你养成用眼与活动的节奏。

基于 SwiftUI 的原生应用(macOS 14+),完全离线运行,无任何网络请求。

## 功能

- **首页**:周期进度环、倒计时、今日休息次数/总时长、暂停 / 立即休息
- **统计**:近 7 天的 24 小时时间轴,三色区分「使用电脑 / 休息 / 暂停·未计时」
- **设置**:使用时长、休息时长、休息前提醒秒数、开机自启、语言、提示音、使用说明与隐私政策
- **菜单栏**:常驻倒计时(休息前变为铃铛),快捷暂停 / 立即休息 / 打开 App / 设置 / 退出
- **全屏休息遮罩**:到点弹出,大倒计时 + 护眼/拉伸提示,可「提前结束」或「稍后 5 分钟」
- **系统通知横幅**:休息前、开始休息、休息结束三个时机,文案跟随应用语言
- **智能计时**:基于 `CGEventSource` 空闲检测,闲置超过 60 秒、锁屏或暂停期间不计入使用时长
- **多语言**:简体中文 / 繁體中文 / English / 日本語,可跟随系统或手动切换,即时生效

## 构建与运行

要求:Xcode 16+(或仅命令行工具 `xcodebuild`),macOS 14+。

```sh
./build.sh                        # Release 构建到 build/Release/TakeRest.app
open build/Release/TakeRest.app   # 启动
```

也可双击 `TakeRest.xcodeproj` 在 Xcode 中打开,直接 ⌘R 运行。

应用为 ad-hoc 本地签名,首次启动请在「系统设置 → 通知」中允许横幅。

## 工程结构

```
TakeRest.xcodeproj          # Xcode 工程(手写,无第三方生成工具)
Info.plist                  # 应用元信息,图标 AppIcon.icns
Resources/AppIcon.icns      # 应用图标
build.sh                    # xcodebuild Release 构建 + LaunchServices 注册
Sources/TakeRest/
  App.swift                 # @main,Window/MenuBarExtra 场景,AppDelegate
  RestEngine.swift          # 核心状态机:工作/暂停/休息,计时与提醒
  SegmentStore.swift        # 时间段(use/rest/off)JSON 持久化,保留 30 天
  Notify.swift              # UNUserNotificationCenter 横幅封装
  BreakWindow.swift         # 全屏休息遮罩(NSWindow + NSHostingView)
  Support.swift             # L10n 四语文案表、主题色、格式化
  Views/                    # Home / Stats / Settings / MenuBar
```

## 数据与隐私

- 使用记录:`~/Library/Application Support/TakeRest/segments.json`
- 偏好设置:`UserDefaults`(时长、语言、开关等)
- 所有数据仅保存在本机,不上传、不收集个人信息

## 已知限制

- 「开机后自动打开 App」依赖 `SMAppService`,从 DerivedData/临时目录运行可能注册失败,安装到稳定路径后生效
- 菜单栏倒计时以应用运行期间为准;系统休眠期间不计入使用时长

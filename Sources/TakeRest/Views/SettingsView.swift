import SwiftUI

/// iOS-style wide pill switch used in the PRD settings card.
struct PillSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(configuration.isOn ? Theme.brown : Color.white)
                    .overlay(Capsule().stroke(Color.black.opacity(configuration.isOn ? 0 : 0.12), lineWidth: 1))
                    .frame(width: 40, height: 24)
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.18), radius: 1.5, y: 1)
                    .frame(width: 20, height: 20)
            }
            .animation(.easeOut(duration: 0.15), value: configuration.isOn)
        }
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture { configuration.isOn.toggle() }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var engine: RestEngine
    @EnvironmentObject private var l10n: L10n
    @ObservedObject private var settings = RestEngine.shared.settings
    @State private var sheet: HelpSheet?

    enum HelpSheet: Identifiable {
        case guide, privacy
        var id: Int { hashValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                section("settings.timing") {
                    stepperRow("settings.work", value: $settings.workMinutes, range: 5...180, unit: "unit.minute")
                    rowDivider
                    stepperRow("settings.rest", value: $settings.restMinutes, range: 1...60, unit: "unit.minute")
                    rowDivider
                    stepperRow("settings.pre", value: $settings.preNotifySeconds, range: 0...300, step: 5, unit: "unit.second")
                }

                section("settings.general") {
                    Toggle(l10n.t("settings.login"), isOn: $settings.launchAtLogin)
                        .toggleStyle(PillSwitchStyle())
                        .font(.system(size: 13))
                    rowDivider
                    HStack {
                        Text(l10n.t("settings.lang")).font(.system(size: 13))
                        Spacer()
                        langMenu
                    }
                    rowDivider
                    Toggle(l10n.t("settings.sound"), isOn: $settings.soundOnRestEnd)
                        .toggleStyle(PillSwitchStyle())
                        .font(.system(size: 13))
                }

                section("settings.help") {
                    helpRow("settings.guide", "settings.guide.btn") { sheet = .guide }
                    rowDivider
                    helpRow("settings.privacy", "settings.privacy.btn") { sheet = .privacy }
                }
            }
            .padding(24)
        }
        .sheet(item: $sheet) { which in
            textSheet(
                title: l10n.t(which == .guide ? "settings.guide" : "settings.privacy"),
                body: l10n.t(which == .guide ? "guide.body" : "privacy.body")
            )
        }
    }

    private func section<C: View>(_ titleKey: String, @ViewBuilder _ content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(l10n.t(titleKey))
                .font(.system(size: 13, weight: .semibold))
            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.card))
        }
    }

    private var rowDivider: some View {
        Divider().overlay(Color.black.opacity(0.06))
    }

    private func stepperRow(_ titleKey: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int = 1, unit: String) -> some View {
        HStack {
            Text(l10n.t(titleKey)).font(.system(size: 13))
            Spacer()
            Text("\(value.wrappedValue) \(l10n.t(unit))")
                .font(.system(size: 13))
                .foregroundStyle(Theme.brown)
                .monospacedDigit()
            Stepper("", value: value, in: range, step: step)
                .labelsHidden()
        }
        .padding(.vertical, 16)
    }

    private var langMenu: some View {
        Menu {
            langItem(.system, "settings.lang.system")
            langItem(.zh, "settings.lang.zh")
            langItem(.zhHant, "settings.lang.zhHant")
            langItem(.ja, "settings.lang.ja")
            langItem(.en, "settings.lang.en")
        } label: {
            HStack(spacing: 4) {
                Text(l10n.t(langKey))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.brown)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
    }

    private func langItem(_ value: AppLang, _ key: String) -> some View {
        Button {
            l10n.setting = value
        } label: {
            if l10n.setting == value {
                Label(l10n.t(key), systemImage: "checkmark")
            } else {
                Text(l10n.t(key))
            }
        }
    }

    private var langKey: String {
        switch l10n.setting {
        case .system: return "settings.lang.system"
        case .zh: return "settings.lang.zh"
        case .zhHant: return "settings.lang.zhHant"
        case .ja: return "settings.lang.ja"
        case .en: return "settings.lang.en"
        }
    }

    private func helpRow(_ titleKey: String, _ btnKey: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(l10n.t(titleKey)).font(.system(size: 13))
            Spacer()
            Button(action: action) {
                Text(l10n.t(btnKey))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.brown)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Theme.pill))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 16)
    }

    private func textSheet(title: String, body text: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.system(size: 15, weight: .semibold))
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.primary.opacity(0.8))
                .textSelection(.enabled)
            HStack { Spacer() }
        }
        .padding(24)
        .frame(width: 420)
    }
}

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var appDataStore: AppDataStore

    @State private var showResetInitialSetupAlert = false
    @State private var showDeleteAllRecordsAlert = false

    private var theme: AppTheme {
        AppTheme.theme(for: appDataStore.settings.selectedTheme)
    }

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    headerSection
                    themeSection
                    currentSettingsSection
                    dataStatusSection
                    resetInitialSetupSection
                    deleteAllRecordsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .onAppear {
            print("===== SettingsView onAppear START =====")
            print("selectedTheme = \(appDataStore.settings.selectedTheme.rawValue)")
            print("maintenanceCalories = \(appDataStore.settings.maintenanceCalories)")
            print("selectedCourse = \(appDataStore.settings.selectedCourse.rawValue)")
            print("goalDirection = \(appDataStore.settings.goalDirection?.rawValue ?? "nil")")
            print("targetDailyBalance = \(appDataStore.settings.targetDailyBalance ?? 0)")
            print("targetTotalBalance = \(appDataStore.settings.targetTotalBalance ?? 0)")
            print("goalDurationDays = \(appDataStore.settings.goalDurationDays ?? 0)")
            print("goalStartDate = \(String(describing: appDataStore.settings.goalStartDate))")
            print("targetDeadline = \(String(describing: appDataStore.settings.targetDeadline))")
            print("targetIntakeCalories = \(appDataStore.settings.targetIntakeCalories ?? 0)")
            print("hasCompletedInitialSetup = \(appDataStore.settings.hasCompletedInitialSetup)")
            print("dailyRecords.count = \(appDataStore.dailyRecords.count)")
            print("historyEntries.count = \(appDataStore.historyEntries.count)")
            print("===== SettingsView onAppear END =====")
        }
        .alert("初期設定をやり直しますか？", isPresented: $showResetInitialSetupAlert) {
            Button("キャンセル", role: .cancel) {
                print("初期設定やり直しをキャンセル")
            }

            Button("やり直す", role: .destructive) {
                resetInitialSetupOnly()
            }
        } message: {
            Text("記録データと履歴は消しません。メンテナンスカロリーや目標設定だけ、もう一度設定し直せる状態にします。")
        }
        .alert("全記録を削除しますか？", isPresented: $showDeleteAllRecordsAlert) {
            Button("キャンセル", role: .cancel) {
                print("全記録削除をキャンセル")
            }

            Button("削除する", role: .destructive) {
                deleteAllRecords()
            }
        } message: {
            Text("日別記録と入力履歴をすべて削除します。この操作は取り消せません。設定・テーマ・初期設定は残ります。")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("設定")
                .font(.system(size: 30, weight: .bold))

            Text("今の目標やテーマを確認できるよ")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Theme

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("テーマ")

            ForEach(AppThemeStyle.allCases, id: \.self) { style in
                Button {
                    changeTheme(to: style)
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(AppTheme.theme(for: style).accent)
                            .frame(width: 22, height: 22)

                        Text(style.displayName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)

                        Spacer()

                        if appDataStore.settings.selectedTheme == style {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(theme.accentDark)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(appDataStore.settings.selectedTheme == style ? theme.accent.opacity(0.18) : Color.white.opacity(0.72))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.card)
        )
    }

    // MARK: - Current Settings

    private var currentSettingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("現在の設定")

            settingsRow(title: "メンテナンスカロリー", value: "\(appDataStore.settings.maintenanceCalories) kcal")
            settingsRow(title: "管理コース", value: courseDisplayName(appDataStore.settings.selectedCourse))
            settingsRow(title: "目標方向", value: appDataStore.settings.goalDirection?.displayName ?? "未設定")
            settingsRow(title: "1日の目標収支", value: optionalCaloriesText(appDataStore.settings.targetDailyBalance))

            if appDataStore.settings.selectedCourse == .diet {
                settingsRow(title: "開始日", value: optionalDateText(appDataStore.settings.goalStartDate))
                settingsRow(title: "期限", value: optionalDateText(appDataStore.settings.targetDeadline))
                settingsRow(title: "目標日数", value: optionalDaysText(appDataStore.settings.goalDurationDays))
                settingsRow(title: "合計目標収支", value: optionalCaloriesText(appDataStore.settings.targetTotalBalance))
            }

            settingsRow(title: "目標摂取カロリー", value: optionalCaloriesText(appDataStore.settings.targetIntakeCalories))
            settingsRow(title: "テーマ", value: appDataStore.settings.selectedTheme.displayName)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.card)
        )
    }

    // MARK: - Data Status

    private var dataStatusSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("保存データ")

            settingsRow(title: "日別記録", value: "\(appDataStore.dailyRecords.count) 件")
            settingsRow(title: "入力履歴", value: "\(appDataStore.historyEntries.count) 件")

            Text("記録だけを削除しても、現在の設定・テーマ・初期設定の状態は残ります。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.card)
        )
    }

    // MARK: - Reset Initial Setup

    private var resetInitialSetupSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("初期設定")

            Text("メンテナンスカロリーや目標を変えたいときは、初期設定だけやり直せます。記録データは消しません。")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .lineSpacing(4)

            Button {
                print("===== reset initial setup button tapped =====")
                showResetInitialSetupAlert = true
            } label: {
                Text("初期設定をやり直す")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.accent)
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.card)
        )
    }

    // MARK: - Delete All Records

    private var deleteAllRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("記録の削除")

            Text("日別記録と入力履歴をすべて削除します。設定やテーマは残ります。")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .lineSpacing(4)

            Button {
                print("===== delete all records button tapped =====")
                showDeleteAllRecordsAlert = true
            } label: {
                Text("全記録を削除")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red.opacity(0.82))
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(appDataStore.dailyRecords.isEmpty && appDataStore.historyEntries.isEmpty)
            .opacity(appDataStore.dailyRecords.isEmpty && appDataStore.historyEntries.isEmpty ? 0.45 : 1.0)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.card)
        )
    }

    // MARK: - Parts

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
    }

    private func settingsRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Actions

    private func changeTheme(to style: AppThemeStyle) {
        print("===== changeTheme START =====")
        print("before selectedTheme = \(appDataStore.settings.selectedTheme.rawValue)")
        print("new selectedTheme = \(style.rawValue)")

        appDataStore.settings.selectedTheme = style
        appDataStore.saveSettings()

        print("after selectedTheme = \(appDataStore.settings.selectedTheme.rawValue)")
        print("===== changeTheme END =====")
    }

    private func resetInitialSetupOnly() {
        print("===== resetInitialSetupOnly START =====")
        print("リセット前 hasCompletedInitialSetup = \(appDataStore.settings.hasCompletedInitialSetup)")
        print("dailyRecords.count = \(appDataStore.dailyRecords.count)")
        print("historyEntries.count = \(appDataStore.historyEntries.count)")

        appDataStore.settings.hasCompletedInitialSetup = false
        appDataStore.saveSettings()

        print("リセット後 hasCompletedInitialSetup = \(appDataStore.settings.hasCompletedInitialSetup)")
        print("記録データは削除していません")
        print("dailyRecords.count = \(appDataStore.dailyRecords.count)")
        print("historyEntries.count = \(appDataStore.historyEntries.count)")
        print("===== resetInitialSetupOnly END =====")
    }

    private func deleteAllRecords() {
        print("===== deleteAllRecords START =====")
        print("削除前 dailyRecords.count = \(appDataStore.dailyRecords.count)")
        print("削除前 historyEntries.count = \(appDataStore.historyEntries.count)")

        appDataStore.deleteAllRecordsAndHistory()

        print("削除後 dailyRecords.count = \(appDataStore.dailyRecords.count)")
        print("削除後 historyEntries.count = \(appDataStore.historyEntries.count)")
        print("===== deleteAllRecords END =====")
    }

    // MARK: - Display Helpers

    private func courseDisplayName(_ course: AppCourse) -> String {
        switch course {
        case .diet:
            return "期限つきで目標管理"
        case .maintenance:
            return "毎日同じ目安で管理"
        }
    }

    private func optionalCaloriesText(_ value: Int?) -> String {
        guard let value else {
            return "未設定"
        }

        if value > 0 {
            return "+\(value) kcal"
        } else {
            return "\(value) kcal"
        }
    }

    private func optionalDaysText(_ value: Int?) -> String {
        guard let value else {
            return "未設定"
        }

        return "\(value)日"
    }

    private func optionalDateText(_ date: Date?) -> String {
        guard let date else {
            return "未設定"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppDataStore())
}

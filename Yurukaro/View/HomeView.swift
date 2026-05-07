import SwiftUI

struct HomeView: View {

    @EnvironmentObject var appDataStore: AppDataStore
    @State private var showRecordInput: Bool = false

    private var theme: AppTheme {
        AppTheme.theme(for: appDataStore.settings.selectedTheme)
    }

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    statusSection
                    actionSection
                    goalProgressSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .sheet(isPresented: $showRecordInput) {
            RecordInputView()
                .environmentObject(appDataStore)
        }
        .onAppear {
            print("===== HomeView onAppear START =====")
            print("selectedTheme = \(appDataStore.settings.selectedTheme.rawValue)")
            print("selectedCourse = \(appDataStore.settings.selectedCourse.rawValue)")
            print("goalStartDate = \(String(describing: appDataStore.settings.goalStartDate))")
            print("todayIntake = \(todayIntake)")
            print("todayExercise = \(todayExercise)")
            print("maintenanceCalories = \(maintenanceCalories)")
            print("balanceValue = \(balanceValue)")
            print("remainingCalories = \(remainingCalories)")
            print("totalBalanceSoFar = \(totalBalanceSoFar)")
            print("remainingGoalBalance = \(remainingGoalBalance ?? 0)")
            print("daysUntilDeadline = \(daysUntilDeadline ?? -999)")
            print("===== HomeView onAppear END =====")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("ゆるカロ")
                .font(.system(size: 32, weight: .bold))

            Text("今日のカロリー状況")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Status

    private var statusSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                infoCard(title: "摂取", value: "\(todayIntake) kcal")
                infoCard(title: "消費", value: "\(todayExercise) kcal")
            }

            infoCard(title: "メンテナンス", value: "\(maintenanceCalories) kcal")
            infoCard(title: "現在の収支", value: "\(balanceText) kcal")
            infoCard(title: "残り摂取可能", value: "\(remainingCalories) kcal")

            HStack {
                Text("目標摂取カロリー")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(targetCalories) kcal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
    }

    private func infoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.card)
        )
    }

    // MARK: - Goal Progress

    private var goalProgressSection: some View {
        Group {
            if appDataStore.settings.selectedCourse == .diet {
                VStack(alignment: .leading, spacing: 14) {
                    Text("目標進捗")
                        .font(.system(size: 20, weight: .bold))

                    HStack(spacing: 12) {
                        progressMiniCard(
                            title: "期限まで",
                            value: daysUntilDeadlineText
                        )

                        progressMiniCard(
                            title: "目標まで",
                            value: remainingGoalBalanceShortText
                        )
                    }

                    VStack(spacing: 10) {
                        detailLine(title: "開始日", value: goalStartDateText)
                        detailLine(title: "現在の累計収支", value: "\(signedText(totalBalanceSoFar)) kcal")
                        detailLine(title: "目標合計収支", value: optionalCaloriesText(appDataStore.settings.targetTotalBalance))
                    }

                    Text(goalProgressMessage)
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
        }
    }

    private func progressMiniCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.accent.opacity(0.16))
        )
    }

    private func detailLine(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .bold))
        }
    }

    // MARK: - Action

    private var actionSection: some View {
        Button {
            print("===== HomeView button tapped START =====")
            showRecordInput = true
            print("showRecordInput = true")
            print("===== HomeView button tapped END =====")
        } label: {
            Text("今日の記録を入力する")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 26)
                        .fill(theme.accent)
                )
                .foregroundStyle(.white)
                .shadow(color: theme.accent.opacity(0.25), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today Data

    private var todayRecord: DailyRecord {
        appDataStore.recordForToday()
    }

    private var todayIntake: Int {
        todayRecord.intakeCalories
    }

    private var todayExercise: Int {
        todayRecord.exerciseCalories
    }

    private var maintenanceCalories: Int {
        appDataStore.settings.maintenanceCalories
    }

    private var balanceValue: Int {
        todayIntake - todayExercise - maintenanceCalories
    }

    private var balanceText: String {
        signedText(balanceValue)
    }

    private var targetCalories: Int {
        appDataStore.settings.targetIntakeCalories ?? 0
    }

    private var remainingCalories: Int {
        targetCalories - todayIntake + todayExercise
    }

    // MARK: - Goal Progress Data

    private var totalBalanceSoFar: Int {
        guard let startDate = appDataStore.settings.goalStartDate else {
            print("goalStartDate が nil のため、累計収支は 0 として表示")
            return 0
        }

        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date())

        let filteredRecords = appDataStore.dailyRecords.filter { record in
            let recordDay = calendar.startOfDay(for: record.date)
            return recordDay >= startDay && recordDay <= today
        }

        print("===== totalBalanceSoFar START =====")
        print("startDay = \(startDay)")
        print("today = \(today)")
        print("filteredRecords.count = \(filteredRecords.count)")

        let total = filteredRecords.reduce(0) { partialResult, record in
            partialResult + record.balance
        }

        print("totalBalanceSoFar = \(total)")
        print("===== totalBalanceSoFar END =====")

        return total
    }

    private var remainingGoalBalance: Int? {
        guard let targetTotalBalance = appDataStore.settings.targetTotalBalance else {
            return nil
        }

        return targetTotalBalance - totalBalanceSoFar
    }

    private var daysUntilDeadline: Int? {
        guard let deadline = appDataStore.settings.targetDeadline else {
            return nil
        }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let deadlineStart = calendar.startOfDay(for: deadline)

        return calendar.dateComponents([.day], from: todayStart, to: deadlineStart).day
    }

    private var goalStartDateText: String {
        guard let startDate = appDataStore.settings.goalStartDate else {
            return "未設定"
        }

        return dateText(startDate)
    }

    private var daysUntilDeadlineText: String {
        guard let daysUntilDeadline else {
            return "未設定"
        }

        if daysUntilDeadline < 0 {
            return "期限後"
        } else if daysUntilDeadline == 0 {
            return "今日まで"
        } else {
            return "あと\(daysUntilDeadline)日"
        }
    }

    private var remainingGoalBalanceShortText: String {
        guard let remainingGoalBalance else {
            return "未設定"
        }

        if remainingGoalBalance == 0 {
            return "達成"
        } else {
            return "あと\(signedText(remainingGoalBalance)) kcal"
        }
    }

    private var goalProgressMessage: String {
        guard appDataStore.settings.goalStartDate != nil else {
            return "開始日が未設定です。初期設定をやり直すと、今日からの目標進捗を正しく計算できます。"
        }

        guard let remainingGoalBalance else {
            return "目標合計収支が未設定です。"
        }

        if let daysUntilDeadline, daysUntilDeadline < 0 {
            return "期限を過ぎています。必要なら初期設定をやり直して、目標を更新してください。"
        }

        if remainingGoalBalance == 0 {
            return "目標収支に到達しています。ここからは無理に削りすぎず、ペースを見て調整してください。"
        }

        if remainingGoalBalance < 0 {
            return "あと\(abs(remainingGoalBalance)) kcal分、マイナス収支を作れば目標に近づきます。"
        } else {
            return "あと\(remainingGoalBalance) kcal分、プラス収支が必要です。食べなさすぎている場合は、無理に削りすぎないでください。"
        }
    }

    // MARK: - Text Helpers

    private func signedText(_ value: Int) -> String {
        value >= 0 ? "+\(value)" : "\(value)"
    }

    private func optionalCaloriesText(_ value: Int?) -> String {
        guard let value else {
            return "未設定"
        }

        return "\(signedText(value)) kcal"
    }

    private func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppDataStore())
}

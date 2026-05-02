import SwiftUI

struct DeadlineGoalSettingView: View {

    @EnvironmentObject var appDataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let enteredMaintenanceCalories: Int

    @State private var selectedDirection: GoalDirection = .minus
    @State private var totalBalanceText: String = ""

    @State private var selectedStartDate: Date = Date()
    @State private var selectedDeadline: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

    @State private var showSavedAlert = false

    private var theme: AppTheme {
        AppTheme.theme(for: appDataStore.settings.selectedTheme)
    }

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    Text("期限つき目標設定")
                        .font(.system(size: 26, weight: .bold))

                    Picker("方向", selection: $selectedDirection) {
                        Text("プラス").tag(GoalDirection.plus)
                        Text("マイナス").tag(GoalDirection.minus)
                        Text("維持").tag(GoalDirection.maintain)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedDirection) { newValue in
                        if newValue == .maintain {
                            totalBalanceText = "0"
                        } else if totalBalanceText == "0" {
                            totalBalanceText = ""
                        }
                    }

                    // 入力
                    VStack(alignment: .leading, spacing: 10) {

                        Text("合計目標収支")
                            .font(.system(size: 15, weight: .semibold))

                        if selectedDirection == .maintain {

                            Text("維持の場合は自動的に 0 kcal")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)

                            Text("0 kcal")
                                .font(.system(size: 18, weight: .bold))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(theme.card)
                                )

                        } else {

                            TextField("例: 7200", text: $totalBalanceText)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.card)
                    )

                    // 日付
                    VStack(spacing: 10) {
                        DatePicker("開始日", selection: $selectedStartDate, displayedComponents: .date)
                        DatePicker("期限", selection: $selectedDeadline, in: selectedStartDate..., displayedComponents: .date)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.card)
                    )

                    // 結果
                    if canCalculate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("日数：\(goalDurationDays)日")
                            Text("1日あたり：\(signedDailyBalanceText) kcal")
                            Text("目標摂取：\(targetIntakeCalories) kcal")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.accent.opacity(0.15))
                        )
                    }

                    // 保存
                    Button {
                        save()
                    } label: {
                        Text("保存")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(canCalculate ? theme.accent : Color.gray)
                            )
                            .foregroundStyle(.white)
                    }
                    .disabled(!canCalculate)

                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .alert("保存しました", isPresented: $showSavedAlert) {
            Button("OK") { dismiss() }
        }
    }

    // MARK: 計算

    private var rawTotalBalance: Int {
        selectedDirection == .maintain ? 0 : (Int(totalBalanceText) ?? 0)
    }

    private var signedTotalBalance: Int {
        selectedDirection == .maintain
        ? 0
        : appDataStore.signedBalance(direction: selectedDirection, rawValue: rawTotalBalance)
    }

    private var goalDurationDays: Int {
        let start = Calendar.current.startOfDay(for: selectedStartDate)
        let end = Calendar.current.startOfDay(for: selectedDeadline)
        return max(Calendar.current.dateComponents([.day], from: start, to: end).day ?? 1, 1)
    }

    private var targetDailyBalance: Int {
        selectedDirection == .maintain ? 0 : signedTotalBalance / goalDurationDays
    }

    private var signedDailyBalanceText: String {
        targetDailyBalance >= 0 ? "+\(targetDailyBalance)" : "\(targetDailyBalance)"
    }

    private var targetIntakeCalories: Int {
        enteredMaintenanceCalories + targetDailyBalance
    }

    private var canCalculate: Bool {
        selectedDirection == .maintain || rawTotalBalance > 0
    }

    // MARK: 保存

    private func save() {
        appDataStore.saveDeadlineCourseSettings(
            direction: selectedDirection,
            totalBalance: signedTotalBalance,
            durationDays: goalDurationDays,
            goalStartDate: selectedStartDate,
            deadline: selectedDeadline,
            dailyBalance: targetDailyBalance,
            targetIntakeCalories: targetIntakeCalories
        )
        showSavedAlert = true
    }
}

#Preview {
    DeadlineGoalSettingView(enteredMaintenanceCalories: 2000)
        .environmentObject(AppDataStore())
}

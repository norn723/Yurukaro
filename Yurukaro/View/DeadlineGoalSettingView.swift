import SwiftUI

struct DeadlineGoalSettingView: View {

    @EnvironmentObject var appDataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let enteredMaintenanceCalories: Int

    @State private var selectedDirection: GoalDirection = .minus
    @State private var totalBalanceText: String = ""

    /// 目標計算を開始する日
    @State private var selectedStartDate: Date = Date()

    /// 目標の期限
    @State private var selectedDeadline: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

    @State private var showSavedAlert = false

    var body: some View {
        VStack(spacing: 20) {

            Text("期限つき目標設定")
                .font(.title.bold())

            Picker("方向", selection: $selectedDirection) {
                Text("プラス").tag(GoalDirection.plus)
                Text("マイナス").tag(GoalDirection.minus)
                Text("維持").tag(GoalDirection.maintain)
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading) {
                Text("合計目標収支")
                    .font(.system(size: 15, weight: .semibold))

                TextField("例: 7200", text: $totalBalanceText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 10) {
                DatePicker(
                    "開始日",
                    selection: $selectedStartDate,
                    displayedComponents: .date
                )

                DatePicker(
                    "期限",
                    selection: $selectedDeadline,
                    in: selectedStartDate...,
                    displayedComponents: .date
                )
            }

            if canCalculate {
                VStack(alignment: .leading, spacing: 8) {
                    Text("開始日：\(dateText(selectedStartDate))")
                    Text("期限：\(dateText(selectedDeadline))")
                    Text("日数：\(goalDurationDays)日")
                    Text("1日あたり：\(targetDailyBalance) kcal")
                    Text("目標摂取：\(targetIntakeCalories) kcal")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                save()
            } label: {
                Text("保存")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canCalculate ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!canCalculate)

            Spacer()
        }
        .padding()
        .onChange(of: selectedStartDate) { _, newValue in
            print("===== selectedStartDate changed =====")
            print("new selectedStartDate = \(newValue)")

            if selectedDeadline < newValue {
                selectedDeadline = Calendar.current.date(byAdding: .day, value: 1, to: newValue) ?? newValue
                print("selectedDeadline adjusted = \(selectedDeadline)")
            }
        }
        .alert("保存しました", isPresented: $showSavedAlert) {
            Button("OK") {
                dismiss()
            }
        }
    }

    // MARK: - 計算

    private var rawTotalBalance: Int {
        Int(totalBalanceText) ?? 0
    }

    private var signedTotalBalance: Int {
        appDataStore.signedBalance(
            direction: selectedDirection,
            rawValue: rawTotalBalance
        )
    }

    private var goalDurationDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: selectedStartDate)
        let deadline = calendar.startOfDay(for: selectedDeadline)

        let days = calendar.dateComponents(
            [.day],
            from: start,
            to: deadline
        ).day ?? 1

        return max(days, 1)
    }

    private var targetDailyBalance: Int {
        signedTotalBalance / goalDurationDays
    }

    private var targetIntakeCalories: Int {
        enteredMaintenanceCalories + targetDailyBalance
    }

    private var canCalculate: Bool {
        rawTotalBalance > 0
    }

    // MARK: - 保存

    private func save() {
        print("===== DeadlineGoalSettingView save START =====")
        print("selectedDirection = \(selectedDirection.rawValue)")
        print("rawTotalBalance = \(rawTotalBalance)")
        print("signedTotalBalance = \(signedTotalBalance)")
        print("selectedStartDate = \(selectedStartDate)")
        print("selectedDeadline = \(selectedDeadline)")
        print("goalDurationDays = \(goalDurationDays)")
        print("targetDailyBalance = \(targetDailyBalance)")
        print("targetIntakeCalories = \(targetIntakeCalories)")

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

        print("===== DeadlineGoalSettingView save END =====")
    }

    // MARK: - Text Helpers

    private func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }
}

#Preview {
    DeadlineGoalSettingView(enteredMaintenanceCalories: 2000)
        .environmentObject(AppDataStore())
}

import SwiftUI

struct DailyBalanceSettingView: View {

    @EnvironmentObject var appDataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let enteredMaintenanceCalories: Int

    @State private var selectedDirection: GoalDirection = .minus
    @State private var rawBalanceText: String = ""

    @State private var showSavedAlert = false

    var body: some View {
        VStack(spacing: 20) {

            Text("毎日の目標設定")
                .font(.title.bold())

            // 方向選択
            Picker("方向", selection: $selectedDirection) {
                Text("プラス").tag(GoalDirection.plus)
                Text("マイナス").tag(GoalDirection.minus)
                Text("維持").tag(GoalDirection.maintain)
            }
            .pickerStyle(.segmented)

            // 入力
            VStack(alignment: .leading) {
                Text("1日の目標収支")
                TextField("例: 300", text: $rawBalanceText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }

            // 計算結果
            if isValid {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1日あたり：\(signedBalance) kcal")
                    Text("目標摂取：\(targetIntakeCalories) kcal")
                }
            }

            // 保存ボタン
            Button {
                save()
            } label: {
                Text("保存")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValid)

            Spacer()
        }
        .padding()
        .alert("保存しました", isPresented: $showSavedAlert) {
            Button("OK") {
                dismiss()
            }
        }
    }

    // MARK: - 計算

    private var rawBalance: Int {
        Int(rawBalanceText) ?? 0
    }

    private var signedBalance: Int {
        appDataStore.signedBalance(
            direction: selectedDirection,
            rawValue: rawBalance
        )
    }

    private var targetIntakeCalories: Int {
        enteredMaintenanceCalories + signedBalance
    }

    private var isValid: Bool {
        rawBalance > 0
    }

    // MARK: - 保存

    private func save() {

        appDataStore.saveMaintenanceCourseSettings(
            direction: selectedDirection,
            dailyBalance: signedBalance,
            targetIntakeCalories: targetIntakeCalories
        )

        showSavedAlert = true
    }
}

#Preview {
    DailyBalanceSettingView(enteredMaintenanceCalories: 2000)
        .environmentObject(AppDataStore())
}

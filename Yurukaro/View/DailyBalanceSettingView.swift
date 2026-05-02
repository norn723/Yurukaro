import SwiftUI

struct DailyBalanceSettingView: View {

    @EnvironmentObject var appDataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let enteredMaintenanceCalories: Int

    @State private var selectedDirection: GoalDirection = .minus
    @State private var rawBalanceText: String = ""
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

                    Text("毎日の目標設定")
                        .font(.system(size: 26, weight: .bold))

                    // 方向選択
                    Picker("方向", selection: $selectedDirection) {
                        Text("プラス").tag(GoalDirection.plus)
                        Text("マイナス").tag(GoalDirection.minus)
                        Text("維持").tag(GoalDirection.maintain)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedDirection) { newValue in
                        if newValue == .maintain {
                            rawBalanceText = "0"
                        } else if rawBalanceText == "0" {
                            rawBalanceText = ""
                        }
                    }

                    // 入力カード
                    VStack(alignment: .leading, spacing: 10) {

                        Text("1日の目標収支")
                            .font(.system(size: 15, weight: .semibold))

                        if selectedDirection == .maintain {

                            Text("維持の場合は自動的に 0 kcal になります")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)

                            Text("0 kcal")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(theme.card)
                                )

                        } else {

                            TextField("例: 300", text: $rawBalanceText)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)

                            Text("プラス：増量 / マイナス：減量の目安")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.card)
                    )

                    // 結果
                    if isValid {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1日あたり：\(signedBalanceText) kcal")
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
                                    .fill(isValid ? theme.accent : Color.gray)
                            )
                            .foregroundStyle(.white)
                    }
                    .disabled(!isValid)

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

    private var rawBalance: Int {
        selectedDirection == .maintain ? 0 : (Int(rawBalanceText) ?? 0)
    }

    private var signedBalance: Int {
        selectedDirection == .maintain
        ? 0
        : appDataStore.signedBalance(direction: selectedDirection, rawValue: rawBalance)
    }

    private var signedBalanceText: String {
        signedBalance >= 0 ? "+\(signedBalance)" : "\(signedBalance)"
    }

    private var targetIntakeCalories: Int {
        enteredMaintenanceCalories + signedBalance
    }

    private var isValid: Bool {
        selectedDirection == .maintain || rawBalance > 0
    }

    // MARK: 保存

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

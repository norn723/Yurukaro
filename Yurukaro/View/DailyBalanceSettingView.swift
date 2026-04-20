//
//  DailyBalanceSettingView.swift
//  Yurukaro
//
//  Created by 衛藤唯花  on 2026/04/18.
//
import SwiftUI

/// コース2：毎日同じ目安で管理 の設定画面
/// ユーザーが 1日の目標収支 と 方向 を決める
struct DailyBalanceSettingView: View {
    @EnvironmentObject var appDataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss

    /// 前の画面で入力されたメンテナンスカロリー
    let enteredMaintenanceCalories: Int

    /// 方向の選択状態
    @State private var selectedDirection: GoalDirection = .maintain

    /// 1日の目標収支入力欄
    @State private var rawBalanceText: String = ""

    /// 保存完了アラート表示用
    @State private var showSavedAlert = false

    var body: some View {
        let theme = appDataStore.settings.selectedTheme.theme

        ThemedScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection(theme: theme)
                    directionSection(theme: theme)
                    balanceInputSection(theme: theme)
                    resultPreviewSection(theme: theme)
                    saveButton(theme: theme)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("毎日の目安設定")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSavedValueIfNeeded()
        }
        .alert("保存しました", isPresented: $showSavedAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("コース2の初期設定を保存しました。")
        }
    }
}

// MARK: - UIパーツ
private extension DailyBalanceSettingView {

    /// 上部タイトル
    @ViewBuilder
    func headerSection(theme: AppTheme) -> some View {
        VStack(spacing: 12) {
            Text("毎日の目安を決めよう")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)
                .multilineTextAlignment(.center)

            Text("期限を決めずに、毎日だいたい同じ収支を目指したい人向けの設定です。")
                .font(.system(size: 14))
                .foregroundStyle(theme.secondaryTextColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    /// 方向選択
    @ViewBuilder
    func directionSection(theme: AppTheme) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("方向を選んでね")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)

            HStack(spacing: 10) {
                directionButton(theme: theme, direction: .plus)
                directionButton(theme: theme, direction: .minus)
                directionButton(theme: theme, direction: .maintain)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ThemedCardBackground(theme: theme)
        }
    }

    /// 方向選択用ボタン
    @ViewBuilder
    func directionButton(theme: AppTheme, direction: GoalDirection) -> some View {
        let isSelected = selectedDirection == direction

        Button {
            selectedDirection = direction

            /// 維持が選ばれた時は、入力値を空にして 0 扱いにする
            if direction == .maintain {
                rawBalanceText = ""
            }
        } label: {
            Text(direction.displayName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isSelected ? theme.buttonTextColor : theme.primaryTextColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isSelected ? theme.buttonColor : theme.surfaceColor.opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isSelected ? theme.buttonColor : Color.white.opacity(0.45),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        }
        .buttonStyle(.plain)
    }

    /// 1日の目標収支入力
    @ViewBuilder
    func balanceInputSection(theme: AppTheme) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("1日の目標収支")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)

            Text("維持を選んだ場合は 0 kcal として扱います。")
                .font(.system(size: 13))
                .foregroundStyle(theme.secondaryTextColor)

            TextField("例：240", text: $rawBalanceText)
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .multilineTextAlignment(.center)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)
                .disabled(selectedDirection == .maintain)
                .opacity(selectedDirection == .maintain ? 0.5 : 1.0)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.78))
                )
                .onChange(of: rawBalanceText) { _, newValue in
                    /// 数字以外が入らないようにする
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        rawBalanceText = filtered
                    }
                }

            Text("kcal / 日")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(theme.secondaryTextColor)

            Text(validationText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isInputValid ? theme.secondaryTextColor : .red)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ThemedCardBackground(theme: theme)
        }
    }

    /// 計算結果プレビュー
    @ViewBuilder
    func resultPreviewSection(theme: AppTheme) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("計算結果プレビュー")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)

            previewRow(
                theme: theme,
                title: "メンテナンスカロリー",
                value: "\(enteredMaintenanceCalories) kcal"
            )

            previewRow(
                theme: theme,
                title: "1日の目標収支",
                value: signedBalanceDisplayText
            )

            previewRow(
                theme: theme,
                title: "目標摂取カロリー",
                value: "\(targetIntakeCalories) kcal"
            )

            Text("計算式：目標摂取カロリー = メンテナンスカロリー + 目標収支")
                .font(.system(size: 13))
                .foregroundStyle(theme.secondaryTextColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ThemedCardBackground(theme: theme)
        }
    }

    /// プレビュー行
    @ViewBuilder
    func previewRow(theme: AppTheme, title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.secondaryTextColor)

            Spacer(minLength: 12)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)
        }
    }

    /// 保存ボタン
    @ViewBuilder
    func saveButton(theme: AppTheme) -> some View {
        Button {
            hideKeyboard()

            appDataStore.saveMaintenanceCourseSettings(
                maintenanceCalories: enteredMaintenanceCalories,
                direction: selectedDirection,
                rawBalanceValue: rawBalanceValue
            )

            showSavedAlert = true
        } label: {
            Text("この内容で保存")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(theme.buttonTextColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(
                        cornerRadius: theme.buttonCornerRadius,
                        style: .continuous
                    )
                    .fill(theme.buttonColor)
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: theme.buttonCornerRadius,
                        style: .continuous
                    )
                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
                )
        }
        .disabled(!isInputValid)
        .opacity(isInputValid ? 1.0 : 0.45)
    }
}

// MARK: - 計算プロパティ
private extension DailyBalanceSettingView {

    /// 入力文字列を Int に変換した値
    var rawBalanceValue: Int {
        Int(rawBalanceText) ?? 0
    }

    /// 実際に計算で使う符号付き収支
    var signedBalanceValue: Int {
        appDataStore.signedBalance(
            direction: selectedDirection,
            rawValue: rawBalanceValue
        )
    }

    /// 目標摂取カロリー
    var targetIntakeCalories: Int {
        enteredMaintenanceCalories + signedBalanceValue
    }

    /// 入力が妥当かどうか
    var isInputValid: Bool {
        switch selectedDirection {
        case .maintain:
            return true
        case .plus, .minus:
            return rawBalanceValue >= 1 && rawBalanceValue <= 3000
        }
    }

    /// 入力案内文
    var validationText: String {
        switch selectedDirection {
        case .maintain:
            return "維持を選んでいるので、目標収支は 0 kcal として保存されます。"
        case .plus, .minus:
            if rawBalanceText.isEmpty {
                return "1〜3000 kcal の範囲で入力してね。"
            }

            if !isInputValid {
                return "入力値を見直してね。1〜3000 kcal の範囲がおすすめです。"
            }

            return "この内容で保存できます。"
        }
    }

    /// 表示用の符号付き収支
    var signedBalanceDisplayText: String {
        if signedBalanceValue > 0 {
            return "+\(signedBalanceValue) kcal"
        } else {
            return "\(signedBalanceValue) kcal"
        }
    }

    /// 保存済みの値があれば初期表示に反映
    func loadSavedValueIfNeeded() {
        if appDataStore.settings.selectedCourse == .maintenance,
           let savedDirection = appDataStore.settings.goalDirection {
            selectedDirection = savedDirection
        }

        if let savedBalance = appDataStore.settings.targetDailyBalance {
            if savedBalance == 0 {
                selectedDirection = .maintain
                rawBalanceText = ""
            } else if savedBalance > 0 {
                selectedDirection = .plus
                rawBalanceText = String(savedBalance)
            } else {
                selectedDirection = .minus
                rawBalanceText = String(abs(savedBalance))
            }
        }
    }
}

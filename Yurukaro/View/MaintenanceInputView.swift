import SwiftUI

/// 初期設定フローの2画面目
/// メンテナンスカロリーを入力するための画面
struct MaintenanceInputView: View {
    @EnvironmentObject var appDataStore: AppDataStore

    /// 入力欄に表示する文字列
    @State private var maintenanceInputText: String = ""

    /// 次画面へ進むフラグ
    @State private var showCourseSelection = false

    var body: some View {
        let theme = appDataStore.settings.selectedTheme.theme

        ThemedScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection(theme: theme)
                    explanationCard(theme: theme)
                    inputCard(theme: theme)
                    nextButton(theme: theme)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("初期設定")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showCourseSelection) {
            CourseSelectionView(
                enteredMaintenanceCalories: maintenanceCaloriesValue
            )
            .environmentObject(appDataStore)
        }
        .onAppear {
            /// すでに設定値がある場合は初期表示に反映する
            if appDataStore.settings.maintenanceCalories > 0 {
                maintenanceInputText = String(appDataStore.settings.maintenanceCalories)
            }
        }
    }
}

// MARK: - UIパーツ
private extension MaintenanceInputView {

    /// 画面上部のタイトル部分
    @ViewBuilder
    func headerSection(theme: AppTheme) -> some View {
        VStack(spacing: 12) {
            Text("まずはここから")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.secondaryTextColor)
                .multilineTextAlignment(.center)

            Text("メンテナンス\nカロリーを入力してね")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text("あとから変更できるから、今わかる範囲で大丈夫。")
                .font(.system(size: 14))
                .foregroundStyle(theme.secondaryTextColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    /// 説明カード
    @ViewBuilder
    func explanationCard(theme: AppTheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("メンテナンスカロリーって？")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)

            Text("1日に体重が増えも減りもしない目安のカロリーです。")
                .font(.system(size: 15))
                .foregroundStyle(theme.primaryTextColor)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text("わからない場合は「メンテナンスカロリー 計算」で調べて、出てきた数字を入力すればOK。")
                .font(.system(size: 14))
                .foregroundStyle(theme.secondaryTextColor)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text("※ この画面ではまだ保存しません。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(theme.secondaryTextColor)
                .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ThemedCardBackground(theme: theme)
        }
    }

    /// 入力カード
    @ViewBuilder
    func inputCard(theme: AppTheme) -> some View {
        VStack(spacing: 16) {
            Text("1日の目安カロリー")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.primaryTextColor)

            TextField("例：1800", text: $maintenanceInputText)
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .multilineTextAlignment(.center)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.78))
                )
                .onChange(of: maintenanceInputText) { _, newValue in
                    /// 数字以外が入らないようにする
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        maintenanceInputText = filtered
                    }
                }

            Text("kcal")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(theme.secondaryTextColor)

            if let validationText {
                Text(validationText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isInputValid ? theme.secondaryTextColor : .red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background {
            ThemedCardBackground(theme: theme)
        }
    }

    /// 次へボタン
    @ViewBuilder
    func nextButton(theme: AppTheme) -> some View {
        Button {
            hideKeyboard()
            showCourseSelection = true
        } label: {
            Text("次へ")
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
private extension MaintenanceInputView {

    /// 入力文字列を Int に変換した値
    var maintenanceCaloriesValue: Int {
        Int(maintenanceInputText) ?? 0
    }

    /// 入力が妥当かどうか
    var isInputValid: Bool {
        let value = maintenanceCaloriesValue
        return value >= 800 && value <= 5000
    }

    /// 入力欄の下に出す案内文
    var validationText: String? {
        if maintenanceInputText.isEmpty {
            return "800〜5000 kcal の範囲で入力してね。"
        }

        if !isInputValid {
            return "入力値を見直してね。800〜5000 kcal の範囲がおすすめです。"
        }

        return "この値で次に進めるよ。"
    }
}

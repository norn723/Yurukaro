import SwiftUI

/// 初期設定フローの3画面目
/// メンテナンスカロリー入力後に、どのコースで管理するか選ぶ画面
struct CourseSelectionView: View {
    @EnvironmentObject var appDataStore: AppDataStore

    /// 前の画面で入力されたメンテナンスカロリー
    let enteredMaintenanceCalories: Int

    /// 毎日同じ目安コースへ進むフラグ
    @State private var showDailyBalanceSetting = false

    /// 期限つきコースの本画面へ進むフラグ
    @State private var showDeadlineGoalSetting = false

    /// この画面で選ばれたコース
    @State private var selectedCourse: AppCourse? = nil

    var body: some View {
        let theme = appDataStore.settings.selectedTheme.theme

        ThemedScreenContainer {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection(theme: theme)
                    currentValueCard(theme: theme)
                    courseButtonsSection(theme: theme)
                    nextButton(theme: theme)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationTitle("コース選択")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showDailyBalanceSetting) {
            DailyBalanceSettingView(
                enteredMaintenanceCalories: enteredMaintenanceCalories
            )
            .environmentObject(appDataStore)
        }
        .navigationDestination(isPresented: $showDeadlineGoalSetting) {
            DeadlineGoalSettingView(
                enteredMaintenanceCalories: enteredMaintenanceCalories
            )
            .environmentObject(appDataStore)
        }
        .onAppear {
            selectedCourse = appDataStore.settings.selectedCourse
        }
    }
}

// MARK: - UIパーツ
private extension CourseSelectionView {

    /// 上部タイトル
    @ViewBuilder
    func headerSection(theme: AppTheme) -> some View {
        VStack(spacing: 12) {
            Text("次はここを選んでね")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.secondaryTextColor)
                .multilineTextAlignment(.center)

            Text("使いたいコースを\n選択しよう")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text("どっちを選んでも、あとで見直しやすい形にしていくよ。")
                .font(.system(size: 14))
                .foregroundStyle(theme.secondaryTextColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    /// 入力済みメンテナンスカロリーの確認カード
    @ViewBuilder
    func currentValueCard(theme: AppTheme) -> some View {
        VStack(spacing: 12) {
            Text("入力したメンテナンスカロリー")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(theme.secondaryTextColor)

            Text("\(enteredMaintenanceCalories) kcal")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(theme.primaryTextColor)

            Text("この値を土台にして、目標摂取カロリーを計算します。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(theme.secondaryTextColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background {
            ThemedCardBackground(theme: theme)
        }
    }

    /// コース選択エリア
    @ViewBuilder
    func courseButtonsSection(theme: AppTheme) -> some View {
        VStack(spacing: 14) {
            courseCard(
                theme: theme,
                title: "期限つきで目標管理",
                description: "未来の日付を選んで、その日までの総目標収支から1日あたりの必要収支を自動で計算します。",
                course: .diet
            )

            courseCard(
                theme: theme,
                title: "毎日同じ目安で管理",
                description: "期限を決めず、毎日だいたい同じ収支を目指したい人向け。維持やゆる管理にも向いています。",
                course: .maintenance
            )
        }
    }

    /// 個別のコースカード
    @ViewBuilder
    func courseCard(
        theme: AppTheme,
        title: String,
        description: String,
        course: AppCourse
    ) -> some View {
        let isSelected = selectedCourse == course

        Button {
            selectedCourse = course
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(
                            isSelected
                            ? theme.buttonColor
                            : theme.secondaryTextColor
                        )

                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(theme.primaryTextColor)
                        .multilineTextAlignment(.leading)
                }

                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(theme.secondaryTextColor)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: theme.cardCornerRadius, style: .continuous)
                    .fill(theme.surfaceColor.opacity(isSelected ? 0.95 : 0.82))
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.cardCornerRadius, style: .continuous)
                    .stroke(
                        isSelected ? theme.buttonColor : Color.white.opacity(0.45),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    /// 次へボタン
    @ViewBuilder
    func nextButton(theme: AppTheme) -> some View {
        Button {
            guard let selectedCourse else { return }

            /// メンテナンスカロリーと選択コースだけ先に保存しておく
            appDataStore.saveCourseSelectionOnly(
                maintenanceCalories: enteredMaintenanceCalories,
                selectedCourse: selectedCourse
            )

            hideKeyboard()

            switch selectedCourse {
            case .diet:
                showDeadlineGoalSetting = true
            case .maintenance:
                showDailyBalanceSetting = true
            }
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
        .disabled(selectedCourse == nil)
        .opacity(selectedCourse == nil ? 0.45 : 1.0)
    }
}

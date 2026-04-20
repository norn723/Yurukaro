import SwiftUI

/// 初期設定フローの最初のスタート画面
struct InitialSetupStartView: View {
    @EnvironmentObject var appDataStore: AppDataStore
    
    /// 次画面へ遷移するフラグ
    @State private var showMaintenanceInput = false

    var body: some View {
        NavigationStack {
            let theme = appDataStore.settings.selectedTheme.theme

            ThemedScreenContainer {
                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 14) {
                        Text("ゆるカロ")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(theme.primaryTextColor)

                        Text("ゆるく続ける、カロリー管理")
                            .font(.headline)
                            .foregroundStyle(theme.secondaryTextColor)

                        Text("食べた分と動いた分を、\nシンプルに見える化しよう。")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    VStack(spacing: 16) {
                        Text("まずは初期設定からはじめよう")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryTextColor)

                        Button {
                            // 次画面へ遷移
                            showMaintenanceInput = true
                        } label: {
                            Text("はじめる")
                                .font(.headline)
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
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            // 👉 次画面への遷移設定
            .navigationDestination(isPresented: $showMaintenanceInput) {
                MaintenanceInputView()
                    .environmentObject(appDataStore)
            }
        }
    }
}

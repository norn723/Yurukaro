import SwiftUI

/// テーマに応じた背景を描画する共通View
/// 背景そのものはレイアウトに干渉させないため、単体では「描画専用」にする
struct ThemedBackgroundView: View {
    /// 適用するテーマ
    let theme: AppTheme

    var body: some View {
        ZStack {
            // ベース背景色
            theme.backgroundColor
                .ignoresSafeArea()

            // 背景柄画像
            // ここでは「画面いっぱいに描く」だけにして、
            // 親のレイアウト計算には参加させない前提で使う
            if let imageName = theme.backgroundPatternImageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                    .opacity(theme.backgroundPatternOpacity)
                    .allowsHitTesting(false)
            }

            // 全体を少しやわらかく見せるための白い膜
            Color.white.opacity(0.04)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }
}

/// テーマに応じた半透明カード背景
struct ThemedCardBackground: View {
    let theme: AppTheme

    var body: some View {
        RoundedRectangle(cornerRadius: theme.cardCornerRadius, style: .continuous)
            .fill(theme.surfaceColor)
            .overlay {
                RoundedRectangle(cornerRadius: theme.cardCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

/// 画面全体をテーマ背景で包む共通コンテナ
/// 背景は content の background / overlay 側に置いて、レイアウトへ干渉させない
struct ThemedScreenContainer<Content: View>: View {
    @EnvironmentObject var appDataStore: AppDataStore

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        let theme = appDataStore.settings.selectedTheme.theme

        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                theme.backgroundColor
                    .ignoresSafeArea()
            }
            .overlay {
                if let imageName = theme.backgroundPatternImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .ignoresSafeArea()
                        .opacity(theme.backgroundPatternOpacity)
                        .allowsHitTesting(false)
                }
            }
            .overlay {
                Color.white.opacity(0.04)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
    }
}

#Preview {
    ThemedBackgroundViewPreview()
        .environmentObject(AppDataStore())
}

/// プレビュー確認用
private struct ThemedBackgroundViewPreview: View {
    @EnvironmentObject var appDataStore: AppDataStore

    var body: some View {
        let theme = appDataStore.settings.selectedTheme.theme

        ThemedScreenContainer {
            VStack(spacing: 20) {
                Text("ゆるカロ")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(theme.primaryTextColor)

                Text("テーマ背景プレビュー")
                    .font(.headline)
                    .foregroundStyle(theme.secondaryTextColor)

                VStack(alignment: .leading, spacing: 12) {
                    Text(theme.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.primaryTextColor)

                    Text("このカード面は今後の初期設定画面や今日画面で共通利用する想定。")
                        .font(.body)
                        .foregroundStyle(theme.secondaryTextColor)
                        .multilineTextAlignment(.leading)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    ThemedCardBackground(theme: theme)
                }
                .padding(.horizontal, 24)
            }
            .padding()
        }
    }
}

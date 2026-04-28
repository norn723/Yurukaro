import SwiftUI

/// テーマの実体（色セット）
struct AppTheme {

    let name: String
    let background: Color
    let accent: Color
    let accentDark: Color
    let card: Color

    /// 互換用：古いViewで使っている名前
    var backgroundColor: Color {
        background
    }

    var surfaceColor: Color {
        card
    }

    var primaryTextColor: Color {
        Color.black.opacity(0.86)
    }

    var secondaryTextColor: Color {
        Color.black.opacity(0.48)
    }

    var buttonTextColor: Color {
        Color.white
    }

    var buttonColor: Color {
        accent
    }

    var buttonCornerRadius: CGFloat {
        18
    }

    var cardCornerRadius: CGFloat {
        24
    }

    /// 今はドット画像を使わないため nil。
    /// ThemedBackgroundView 側がこの値を見ても落ちないように残す。
    var backgroundPatternImageName: String? {
        nil
    }
    
    var backgroundPatternOpacity: Double {
        0.0
    }

    /// テーマ生成
    static func theme(for style: AppThemeStyle) -> AppTheme {
        switch style {

        case .mint:
            return AppTheme(
                name: "ミント",
                background: Color(red: 0.88, green: 0.98, blue: 0.95),
                accent: Color(red: 0.48, green: 0.82, blue: 0.75),
                accentDark: Color(red: 0.28, green: 0.70, blue: 0.62),
                card: Color.white.opacity(0.96)
            )

        case .pink:
            return AppTheme(
                name: "ピンク",
                background: Color(red: 1.00, green: 0.92, blue: 0.95),
                accent: Color(red: 1.00, green: 0.56, blue: 0.72),
                accentDark: Color(red: 0.88, green: 0.34, blue: 0.56),
                card: Color.white.opacity(0.96)
            )

        case .lavender:
            return AppTheme(
                name: "ラベンダー",
                background: Color(red: 0.95, green: 0.92, blue: 1.00),
                accent: Color(red: 0.66, green: 0.56, blue: 0.90),
                accentDark: Color(red: 0.50, green: 0.40, blue: 0.76),
                card: Color.white.opacity(0.96)
            )
        }
    }
}

/// AppThemeStyle.theme という古い書き方にも対応させる
extension AppThemeStyle {

    var theme: AppTheme {
        AppTheme.theme(for: self)
    }
}

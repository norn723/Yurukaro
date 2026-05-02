import SwiftUI

struct AppTheme {

    let name: String
    let background: Color
    let card: Color
    let accent: Color
    let accentDark: Color

    // MARK: - 互換用プロパティ

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

    var backgroundPatternImageName: String? {
        nil
    }

    var backgroundPatternOpacity: Double {
        0.0
    }

    // MARK: - Theme Factory

    static func theme(for style: AppThemeStyle) -> AppTheme {
        switch style {

        case .mint:
            return AppTheme(
                name: "ミント",
                background: Color(red: 0.85, green: 0.98, blue: 0.95),
                card: Color.white.opacity(0.9),
                accent: Color.mint,
                accentDark: Color.green
            )

        case .pink:
            return AppTheme(
                name: "ピンク",
                background: Color(red: 1.0, green: 0.9, blue: 0.95),
                card: Color.white.opacity(0.9),
                accent: Color.pink,
                accentDark: Color.red
            )

        case .lavender:
            return AppTheme(
                name: "ラベンダー",
                background: Color(red: 0.93, green: 0.9, blue: 1.0),
                card: Color.white.opacity(0.9),
                accent: Color.purple,
                accentDark: Color.purple.opacity(0.8)
            )

        case .peach:
            return AppTheme(
                name: "ピーチ",
                background: Color(red: 1.0, green: 0.92, blue: 0.85),
                card: Color.white.opacity(0.9),
                accent: Color.orange,
                accentDark: Color.orange.opacity(0.8)
            )

        case .sky:
            return AppTheme(
                name: "スカイ",
                background: Color(red: 0.85, green: 0.93, blue: 1.0),
                card: Color.white.opacity(0.9),
                accent: Color.blue,
                accentDark: Color.blue.opacity(0.8)
            )

        case .lemon:
            return AppTheme(
                name: "レモン",
                background: Color(red: 1.0, green: 1.0, blue: 0.85),
                card: Color.white.opacity(0.9),
                accent: Color.yellow,
                accentDark: Color.orange
            )
        }
    }
}

extension AppThemeStyle {

    var theme: AppTheme {
        AppTheme.theme(for: self)
    }
}

//
//  AppTheme.swift
//  Yurukaro
//
//  Created by 衛藤唯花 on 2026/04/18.
//

import SwiftUI

struct AppTheme {
    let name: String
    let backgroundColor: Color
    let surfaceColor: Color
    let primaryTextColor: Color
    let secondaryTextColor: Color
    let buttonColor: Color
    let buttonTextColor: Color
    let accentColor: Color
    let backgroundPatternImageName: String?
    let backgroundPatternOpacity: Double
    let buttonCornerRadius: CGFloat
    let cardCornerRadius: CGFloat
}

extension AppThemeStyle {
    var theme: AppTheme {
        switch self {
        case .mint:
            return AppTheme(
                name: "ミントドット",
                backgroundColor: Color(red: 0.88, green: 0.96, blue: 0.95),
                surfaceColor: Color.white.opacity(0.58),
                primaryTextColor: Color(red: 0.22, green: 0.28, blue: 0.30),
                secondaryTextColor: Color(red: 0.42, green: 0.49, blue: 0.50),
                buttonColor: Color.white.opacity(0.35),
                buttonTextColor: Color(red: 0.20, green: 0.27, blue: 0.29),
                accentColor: Color(red: 0.63, green: 0.84, blue: 0.81),
                backgroundPatternImageName: "theme_mint_dots",
                backgroundPatternOpacity: 0.30,
                buttonCornerRadius: 18,
                cardCornerRadius: 24
            )

        case .pink:
            return AppTheme(
                name: "ピンクドット",
                backgroundColor: Color(red: 1.00, green: 0.93, blue: 0.95),
                surfaceColor: Color.white.opacity(0.58),
                primaryTextColor: Color(red: 0.34, green: 0.25, blue: 0.29),
                secondaryTextColor: Color(red: 0.53, green: 0.42, blue: 0.46),
                buttonColor: Color.white.opacity(0.35),
                buttonTextColor: Color(red: 0.34, green: 0.25, blue: 0.29),
                accentColor: Color(red: 0.97, green: 0.72, blue: 0.79),
                backgroundPatternImageName: "theme_pink_dots",
                backgroundPatternOpacity: 0.30,
                buttonCornerRadius: 18,
                cardCornerRadius: 24
            )

        case .lavender:
            return AppTheme(
                name: "ラベンダードット",
                backgroundColor: Color(red: 0.95, green: 0.93, blue: 1.00),
                surfaceColor: Color.white.opacity(0.58),
                primaryTextColor: Color(red: 0.28, green: 0.25, blue: 0.36),
                secondaryTextColor: Color(red: 0.45, green: 0.42, blue: 0.56),
                buttonColor: Color.white.opacity(0.35),
                buttonTextColor: Color(red: 0.28, green: 0.25, blue: 0.36),
                accentColor: Color(red: 0.77, green: 0.71, blue: 0.96),
                backgroundPatternImageName: "theme_lavender_dots",
                backgroundPatternOpacity: 0.30,
                buttonCornerRadius: 18,
                cardCornerRadius: 24
            )
        }
    }
}

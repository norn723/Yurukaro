//
//  AppSettings.swift
//  Yurukaro
//
//  Created by 衛藤唯花 on 2026/04/17.
//

import Foundation

/// アプリのコース種類
enum AppCourse: String, Codable {
    /// コース1：期限つきで目標管理
    case diet

    /// コース2：毎日同じ目安で管理
    case maintenance
}

/// 目標収支の方向
enum GoalDirection: String, Codable, CaseIterable {
    case plus
    case minus
    case maintain

    /// 画面表示用の名前
    var displayName: String {
        switch self {
        case .plus:
            return "プラス"
        case .minus:
            return "マイナス"
        case .maintain:
            return "維持"
        }
    }

    /// 計算用の符号
    /// plus = +1 / minus = -1 / maintain = 0
    var sign: Int {
        switch self {
        case .plus:
            return 1
        case .minus:
            return -1
        case .maintain:
            return 0
        }
    }
}

/// アプリのテーマ種類
enum AppThemeStyle: String, Codable, CaseIterable {
    case mint
    case pink
    case lavender

    /// 設定画面などで表示する用の名前
    var displayName: String {
        switch self {
        case .mint:
            return "ミントドット"
        case .pink:
            return "ピンクドット"
        case .lavender:
            return "ラベンダードット"
        }
    }
}

/// アプリ全体の設定モデル
struct AppSettings: Codable {

    /// メンテナンスカロリー
    var maintenanceCalories: Int

    /// 選択中のコース
    var selectedCourse: AppCourse

    /// 選択中の方向
    var goalDirection: GoalDirection?

    /// 共通で使う：1日の目標収支
    /// 例）-240 / 0 / +150
    var targetDailyBalance: Int?

    /// コース1用：合計目標収支
    /// 例）-7200
    var targetTotalBalance: Int?

    /// コース1用：目標日数
    var goalDurationDays: Int?

    /// コース1用：期限
    var targetDeadline: Date?

    /// 共通で使う：目標摂取カロリー
    /// 例）1360
    var targetIntakeCalories: Int?

    /// 初期設定が終わっているかどうか
    var hasCompletedInitialSetup: Bool

    /// 選択中のテーマ
    var selectedTheme: AppThemeStyle

    /// 通常の初期値
    init(
        maintenanceCalories: Int = 0,
        selectedCourse: AppCourse = .maintenance,
        goalDirection: GoalDirection? = nil,
        targetDailyBalance: Int? = nil,
        targetTotalBalance: Int? = nil,
        goalDurationDays: Int? = nil,
        targetDeadline: Date? = nil,
        targetIntakeCalories: Int? = nil,
        hasCompletedInitialSetup: Bool = false,
        selectedTheme: AppThemeStyle = .mint
    ) {
        self.maintenanceCalories = maintenanceCalories
        self.selectedCourse = selectedCourse
        self.goalDirection = goalDirection
        self.targetDailyBalance = targetDailyBalance
        self.targetTotalBalance = targetTotalBalance
        self.goalDurationDays = goalDurationDays
        self.targetDeadline = targetDeadline
        self.targetIntakeCalories = targetIntakeCalories
        self.hasCompletedInitialSetup = hasCompletedInitialSetup
        self.selectedTheme = selectedTheme
    }

    /// 保存済みデータの読込用キー
    /// 後からプロパティが増えても落ちにくくするために明示している
    enum CodingKeys: String, CodingKey {
        case maintenanceCalories
        case selectedCourse
        case goalDirection
        case targetDailyBalance
        case targetTotalBalance
        case goalDurationDays
        case targetDeadline
        case targetIntakeCalories
        case hasCompletedInitialSetup
        case selectedTheme
    }

    /// 古い保存データにも対応するためのデコード処理
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.maintenanceCalories = try container.decodeIfPresent(Int.self, forKey: .maintenanceCalories) ?? 0
        self.selectedCourse = try container.decodeIfPresent(AppCourse.self, forKey: .selectedCourse) ?? .maintenance
        self.goalDirection = try container.decodeIfPresent(GoalDirection.self, forKey: .goalDirection)
        self.targetDailyBalance = try container.decodeIfPresent(Int.self, forKey: .targetDailyBalance)
        self.targetTotalBalance = try container.decodeIfPresent(Int.self, forKey: .targetTotalBalance)
        self.goalDurationDays = try container.decodeIfPresent(Int.self, forKey: .goalDurationDays)
        self.targetDeadline = try container.decodeIfPresent(Date.self, forKey: .targetDeadline)
        self.targetIntakeCalories = try container.decodeIfPresent(Int.self, forKey: .targetIntakeCalories)
        self.hasCompletedInitialSetup = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedInitialSetup) ?? false
        self.selectedTheme = try container.decodeIfPresent(AppThemeStyle.self, forKey: .selectedTheme) ?? .mint
    }

    /// 通常の保存処理
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(maintenanceCalories, forKey: .maintenanceCalories)
        try container.encode(selectedCourse, forKey: .selectedCourse)
        try container.encode(goalDirection, forKey: .goalDirection)
        try container.encode(targetDailyBalance, forKey: .targetDailyBalance)
        try container.encode(targetTotalBalance, forKey: .targetTotalBalance)
        try container.encode(goalDurationDays, forKey: .goalDurationDays)
        try container.encode(targetDeadline, forKey: .targetDeadline)
        try container.encode(targetIntakeCalories, forKey: .targetIntakeCalories)
        try container.encode(hasCompletedInitialSetup, forKey: .hasCompletedInitialSetup)
        try container.encode(selectedTheme, forKey: .selectedTheme)
    }
}

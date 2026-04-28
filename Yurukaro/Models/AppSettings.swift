import Foundation

enum AppCourse: String, Codable {
    case diet
    case maintenance
}

enum GoalDirection: String, Codable, CaseIterable {
    case plus
    case minus
    case maintain

    var displayName: String {
        switch self {
        case .plus: return "プラス"
        case .minus: return "マイナス"
        case .maintain: return "維持"
        }
    }

    var sign: Int {
        switch self {
        case .plus: return 1
        case .minus: return -1
        case .maintain: return 0
        }
    }
}

enum AppThemeStyle: String, Codable, CaseIterable {
    case mint
    case pink
    case lavender

    var displayName: String {
        switch self {
        case .mint: return "ミント"
        case .pink: return "ピンク"
        case .lavender: return "ラベンダー"
        }
    }
}

struct AppSettings: Codable {

    var maintenanceCalories: Int
    var selectedCourse: AppCourse
    var goalDirection: GoalDirection?

    var targetDailyBalance: Int?
    var targetTotalBalance: Int?
    var goalDurationDays: Int?

    /// 目標の開始日
    var goalStartDate: Date?

    /// 目標の期限日
    var targetDeadline: Date?

    var targetIntakeCalories: Int?
    var hasCompletedInitialSetup: Bool
    var selectedTheme: AppThemeStyle

    init(
        maintenanceCalories: Int = 0,
        selectedCourse: AppCourse = .maintenance,
        goalDirection: GoalDirection? = nil,
        targetDailyBalance: Int? = nil,
        targetTotalBalance: Int? = nil,
        goalDurationDays: Int? = nil,
        goalStartDate: Date? = nil,
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
        self.goalStartDate = goalStartDate
        self.targetDeadline = targetDeadline
        self.targetIntakeCalories = targetIntakeCalories
        self.hasCompletedInitialSetup = hasCompletedInitialSetup
        self.selectedTheme = selectedTheme
    }

    enum CodingKeys: String, CodingKey {
        case maintenanceCalories
        case selectedCourse
        case goalDirection
        case targetDailyBalance
        case targetTotalBalance
        case goalDurationDays
        case goalStartDate
        case targetDeadline
        case targetIntakeCalories
        case hasCompletedInitialSetup
        case selectedTheme
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.maintenanceCalories = try container.decodeIfPresent(Int.self, forKey: .maintenanceCalories) ?? 0
        self.selectedCourse = try container.decodeIfPresent(AppCourse.self, forKey: .selectedCourse) ?? .maintenance
        self.goalDirection = try container.decodeIfPresent(GoalDirection.self, forKey: .goalDirection)
        self.targetDailyBalance = try container.decodeIfPresent(Int.self, forKey: .targetDailyBalance)
        self.targetTotalBalance = try container.decodeIfPresent(Int.self, forKey: .targetTotalBalance)
        self.goalDurationDays = try container.decodeIfPresent(Int.self, forKey: .goalDurationDays)
        self.goalStartDate = try container.decodeIfPresent(Date.self, forKey: .goalStartDate)
        self.targetDeadline = try container.decodeIfPresent(Date.self, forKey: .targetDeadline)
        self.targetIntakeCalories = try container.decodeIfPresent(Int.self, forKey: .targetIntakeCalories)
        self.hasCompletedInitialSetup = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedInitialSetup) ?? false
        self.selectedTheme = try container.decodeIfPresent(AppThemeStyle.self, forKey: .selectedTheme) ?? .mint
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(maintenanceCalories, forKey: .maintenanceCalories)
        try container.encode(selectedCourse, forKey: .selectedCourse)
        try container.encode(goalDirection, forKey: .goalDirection)
        try container.encode(targetDailyBalance, forKey: .targetDailyBalance)
        try container.encode(targetTotalBalance, forKey: .targetTotalBalance)
        try container.encode(goalDurationDays, forKey: .goalDurationDays)
        try container.encode(goalStartDate, forKey: .goalStartDate)
        try container.encode(targetDeadline, forKey: .targetDeadline)
        try container.encode(targetIntakeCalories, forKey: .targetIntakeCalories)
        try container.encode(hasCompletedInitialSetup, forKey: .hasCompletedInitialSetup)
        try container.encode(selectedTheme, forKey: .selectedTheme)
    }
}

import Foundation

/// 1回ごとの入力履歴を表すモデル
struct RecordHistoryEntry: Identifiable, Codable {

    /// 一意のID
    let id: UUID

    /// どの日の記録に対する操作か
    let targetDate: Date

    /// 実際に入力した日時
    let createdAt: Date

    /// 摂取 or 消費
    let type: EntryType

    /// 増減値
    /// 例:
    /// +200 -> 200
    /// -50  -> -50
    let calories: Int

    init(
        id: UUID = UUID(),
        targetDate: Date,
        createdAt: Date = Date(),
        type: EntryType,
        calories: Int
    ) {
        self.id = id
        self.targetDate = targetDate
        self.createdAt = createdAt
        self.type = type
        self.calories = calories
    }

    enum EntryType: String, Codable {
        case intake
        case exercise

        var displayTitle: String {
            switch self {
            case .intake:
                return "摂取"
            case .exercise:
                return "消費"
            }
        }
    }
}

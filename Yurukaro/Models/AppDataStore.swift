import Foundation
import Combine

final class AppDataStore: ObservableObject {

    @Published var settings: AppSettings = AppSettings()
    @Published var dailyRecords: [DailyRecord] = []
    @Published var historyEntries: [RecordHistoryEntry] = []

    private let settingsKey = "app_settings"
    private let dailyRecordsKey = "daily_records"
    private let historyEntriesKey = "history_entries"

    init() {
        print("===== AppDataStore init START =====")
        loadSettings()
        loadRecords()
        loadHistoryEntries()
        print("maintenanceCalories = \(settings.maintenanceCalories)")
        print("selectedCourse = \(settings.selectedCourse.rawValue)")
        print("goalDirection = \(settings.goalDirection?.rawValue ?? "nil")")
        print("goalStartDate = \(String(describing: settings.goalStartDate))")
        print("targetDeadline = \(String(describing: settings.targetDeadline))")
        print("targetIntakeCalories = \(settings.targetIntakeCalories ?? 0)")
        print("dailyRecords.count = \(dailyRecords.count)")
        print("historyEntries.count = \(historyEntries.count)")
        print("===== AppDataStore init END =====")
    }

    // MARK: - 設定保存 / 読込

    func saveSettings() {
        print("===== saveSettings START =====")
        print("maintenanceCalories = \(settings.maintenanceCalories)")
        print("selectedCourse = \(settings.selectedCourse.rawValue)")
        print("goalDirection = \(settings.goalDirection?.rawValue ?? "nil")")
        print("targetDailyBalance = \(settings.targetDailyBalance ?? 0)")
        print("targetTotalBalance = \(settings.targetTotalBalance ?? 0)")
        print("goalDurationDays = \(settings.goalDurationDays ?? 0)")
        print("goalStartDate = \(String(describing: settings.goalStartDate))")
        print("targetDeadline = \(String(describing: settings.targetDeadline))")
        print("targetIntakeCalories = \(settings.targetIntakeCalories ?? 0)")
        print("hasCompletedInitialSetup = \(settings.hasCompletedInitialSetup)")
        print("selectedTheme = \(settings.selectedTheme.rawValue)")

        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
            print("設定保存成功")
        } else {
            print("ERROR: 設定保存失敗")
        }

        print("===== saveSettings END =====")
    }

    private func loadSettings() {
        print("===== loadSettings START =====")

        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
            print("設定読込成功")
        } else {
            print("設定なし or 読込失敗。デフォルト設定を使用")
        }

        print("maintenanceCalories = \(settings.maintenanceCalories)")
        print("selectedCourse = \(settings.selectedCourse.rawValue)")
        print("goalDirection = \(settings.goalDirection?.rawValue ?? "nil")")
        print("targetDailyBalance = \(settings.targetDailyBalance ?? 0)")
        print("targetTotalBalance = \(settings.targetTotalBalance ?? 0)")
        print("goalDurationDays = \(settings.goalDurationDays ?? 0)")
        print("goalStartDate = \(String(describing: settings.goalStartDate))")
        print("targetDeadline = \(String(describing: settings.targetDeadline))")
        print("targetIntakeCalories = \(settings.targetIntakeCalories ?? 0)")
        print("hasCompletedInitialSetup = \(settings.hasCompletedInitialSetup)")
        print("selectedTheme = \(settings.selectedTheme.rawValue)")
        print("===== loadSettings END =====")
    }

    // MARK: - 日別記録保存 / 読込

    private func saveRecords() {
        print("===== saveRecords START =====")
        print("保存対象件数 = \(dailyRecords.count)")

        for (index, record) in dailyRecords.enumerated() {
            print("[\(index)] date = \(record.date), intake = \(record.intakeCalories), exercise = \(record.exerciseCalories), maintenance = \(record.maintenanceCalories), balance = \(record.balance)")
        }

        if let data = try? JSONEncoder().encode(dailyRecords) {
            UserDefaults.standard.set(data, forKey: dailyRecordsKey)
            print("日別記録保存成功")
        } else {
            print("ERROR: 日別記録保存失敗")
        }

        print("===== saveRecords END =====")
    }

    private func loadRecords() {
        print("===== loadRecords START =====")

        if let data = UserDefaults.standard.data(forKey: dailyRecordsKey),
           let decoded = try? JSONDecoder().decode([DailyRecord].self, from: data) {
            dailyRecords = decoded
            print("日別記録読込成功")
        } else {
            print("日別記録なし or 読込失敗。空配列を使用")
        }

        print("読込件数 = \(dailyRecords.count)")

        for (index, record) in dailyRecords.enumerated() {
            print("[\(index)] date = \(record.date), intake = \(record.intakeCalories), exercise = \(record.exerciseCalories), maintenance = \(record.maintenanceCalories), balance = \(record.balance)")
        }

        print("===== loadRecords END =====")
    }

    // MARK: - 履歴保存 / 読込

    private func saveHistoryEntries() {
        print("===== saveHistoryEntries START =====")
        print("保存対象件数 = \(historyEntries.count)")

        for (index, entry) in historyEntries.enumerated() {
            print("[\(index)] targetDate = \(entry.targetDate), createdAt = \(entry.createdAt), type = \(entry.type.rawValue), calories = \(entry.calories)")
        }

        if let data = try? JSONEncoder().encode(historyEntries) {
            UserDefaults.standard.set(data, forKey: historyEntriesKey)
            print("履歴保存成功")
        } else {
            print("ERROR: 履歴保存失敗")
        }

        print("===== saveHistoryEntries END =====")
    }

    private func loadHistoryEntries() {
        print("===== loadHistoryEntries START =====")

        if let data = UserDefaults.standard.data(forKey: historyEntriesKey),
           let decoded = try? JSONDecoder().decode([RecordHistoryEntry].self, from: data) {
            historyEntries = decoded
            print("履歴読込成功")
        } else {
            print("履歴なし or 読込失敗。空配列を使用")
        }

        print("読込件数 = \(historyEntries.count)")

        for (index, entry) in historyEntries.enumerated() {
            print("[\(index)] targetDate = \(entry.targetDate), createdAt = \(entry.createdAt), type = \(entry.type.rawValue), calories = \(entry.calories)")
        }

        print("===== loadHistoryEntries END =====")
    }

    // MARK: - 日別記録取得

    func record(for date: Date) -> DailyRecord? {
        print("===== record(for:) START =====")
        print("検索日付 = \(date)")

        let result = dailyRecords.first {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }

        if let record = result {
            print("記録あり")
            print("intake = \(record.intakeCalories)")
            print("exercise = \(record.exerciseCalories)")
            print("maintenance = \(record.maintenanceCalories)")
            print("balance = \(record.balance)")
        } else {
            print("記録なし")
        }

        print("===== record(for:) END =====")
        return result
    }

    func recordForToday() -> DailyRecord {
        print("===== recordForToday START =====")

        if let record = record(for: Date()) {
            print("今日の既存記録を返す")
            print("===== recordForToday END =====")
            return record
        }

        let emptyRecord = DailyRecord(
            date: Date(),
            intakeCalories: 0,
            exerciseCalories: 0,
            maintenanceCalories: settings.maintenanceCalories
        )

        print("今日の記録がないため空レコードを返す")
        print("intake = \(emptyRecord.intakeCalories)")
        print("exercise = \(emptyRecord.exerciseCalories)")
        print("maintenance = \(emptyRecord.maintenanceCalories)")
        print("balance = \(emptyRecord.balance)")
        print("===== recordForToday END =====")

        return emptyRecord
    }

    // MARK: - 履歴取得

    func historyEntries(for date: Date) -> [RecordHistoryEntry] {
        print("===== historyEntries(for:) START =====")
        print("検索日付 = \(date)")

        let result = historyEntries
            .filter { Calendar.current.isDate($0.targetDate, inSameDayAs: date) }
            .sorted { $0.createdAt > $1.createdAt }

        print("該当件数 = \(result.count)")
        print("===== historyEntries(for:) END =====")

        return result
    }

    func addHistoryEntry(_ entry: RecordHistoryEntry) {
        print("===== addHistoryEntry START =====")
        print("targetDate = \(entry.targetDate)")
        print("createdAt = \(entry.createdAt)")
        print("type = \(entry.type.rawValue)")
        print("calories = \(entry.calories)")

        historyEntries.append(entry)
        saveHistoryEntries()

        print("保存後件数 = \(historyEntries.count)")
        print("===== addHistoryEntry END =====")
    }

    func addHistoryEntries(_ entries: [RecordHistoryEntry]) {
        print("===== addHistoryEntries START =====")
        print("追加件数 = \(entries.count)")

        guard !entries.isEmpty else {
            print("追加対象なし")
            print("===== addHistoryEntries END =====")
            return
        }

        historyEntries.append(contentsOf: entries)
        saveHistoryEntries()

        print("保存後件数 = \(historyEntries.count)")
        print("===== addHistoryEntries END =====")
    }

    // MARK: - 日別記録保存

    func upsertRecord(_ newRecord: DailyRecord) {
        print("===== upsertRecord START =====")
        print("保存対象 date = \(newRecord.date)")
        print("保存対象 intake = \(newRecord.intakeCalories)")
        print("保存対象 exercise = \(newRecord.exerciseCalories)")
        print("保存対象 maintenance = \(newRecord.maintenanceCalories)")
        print("保存対象 balance = \(newRecord.balance)")
        print("保存前件数 = \(dailyRecords.count)")

        if let index = dailyRecords.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: newRecord.date)
        }) {
            print("同日の既存記録あり → 上書き index = \(index)")
            dailyRecords[index] = newRecord
        } else {
            print("同日の記録なし → 新規追加")
            dailyRecords.append(newRecord)
        }

        print("保存後件数 = \(dailyRecords.count)")
        saveRecords()
        print("===== upsertRecord END =====")
    }

    // MARK: - 全記録削除

    /// 日別記録と入力履歴をすべて削除する。
    /// 設定・テーマ・初期設定状態は削除しない。
    func deleteAllRecordsAndHistory() {
        print("===== deleteAllRecordsAndHistory START =====")
        print("削除前 dailyRecords.count = \(dailyRecords.count)")
        print("削除前 historyEntries.count = \(historyEntries.count)")
        print("設定は削除しません")
        print("selectedTheme = \(settings.selectedTheme.rawValue)")
        print("hasCompletedInitialSetup = \(settings.hasCompletedInitialSetup)")

        dailyRecords.removeAll()
        historyEntries.removeAll()

        saveRecords()
        saveHistoryEntries()

        print("削除後 dailyRecords.count = \(dailyRecords.count)")
        print("削除後 historyEntries.count = \(historyEntries.count)")
        print("===== deleteAllRecordsAndHistory END =====")
    }

    // MARK: - 残りカロリー計算

    func remainingCaloriesForToday(on date: Date) -> Int? {
        print("===== remainingCaloriesForToday START =====")
        print("計算対象日 = \(date)")

        guard let target = settings.targetIntakeCalories else {
            print("targetIntakeCalories が nil のため計算不可")
            print("===== remainingCaloriesForToday END =====")
            return nil
        }

        let record = record(for: date) ?? DailyRecord(
            date: date,
            intakeCalories: 0,
            exerciseCalories: 0,
            maintenanceCalories: settings.maintenanceCalories
        )

        let remaining = target - record.intakeCalories + record.exerciseCalories

        print("target = \(target)")
        print("intake = \(record.intakeCalories)")
        print("exercise = \(record.exerciseCalories)")
        print("remaining = \(remaining)")
        print("===== remainingCaloriesForToday END =====")

        return remaining
    }

    // MARK: - コース保存

    func saveCourseSelectionOnly(
        maintenanceCalories: Int,
        selectedCourse: AppCourse
    ) {
        print("===== saveCourseSelectionOnly START =====")
        print("maintenanceCalories = \(maintenanceCalories)")
        print("selectedCourse = \(selectedCourse.rawValue)")

        settings.maintenanceCalories = maintenanceCalories
        settings.selectedCourse = selectedCourse
        saveSettings()

        print("===== saveCourseSelectionOnly END =====")
    }

    func saveMaintenanceCourseSettings(
        direction: GoalDirection,
        dailyBalance: Int,
        targetIntakeCalories: Int
    ) {
        print("===== saveMaintenanceCourseSettings START =====")
        print("direction = \(direction.rawValue)")
        print("dailyBalance = \(dailyBalance)")
        print("targetIntakeCalories = \(targetIntakeCalories)")

        settings.goalDirection = direction
        settings.targetDailyBalance = dailyBalance
        settings.targetTotalBalance = nil
        settings.goalDurationDays = nil
        settings.goalStartDate = nil
        settings.targetDeadline = nil
        settings.targetIntakeCalories = targetIntakeCalories
        settings.hasCompletedInitialSetup = true

        saveSettings()

        print("===== saveMaintenanceCourseSettings END =====")
    }

    func saveDeadlineCourseSettings(
        direction: GoalDirection,
        totalBalance: Int,
        durationDays: Int,
        goalStartDate: Date,
        deadline: Date,
        dailyBalance: Int,
        targetIntakeCalories: Int
    ) {
        print("===== saveDeadlineCourseSettings START =====")
        print("direction = \(direction.rawValue)")
        print("totalBalance = \(totalBalance)")
        print("durationDays = \(durationDays)")
        print("goalStartDate = \(goalStartDate)")
        print("deadline = \(deadline)")
        print("dailyBalance = \(dailyBalance)")
        print("targetIntakeCalories = \(targetIntakeCalories)")

        settings.goalDirection = direction
        settings.targetTotalBalance = totalBalance
        settings.goalDurationDays = durationDays
        settings.goalStartDate = goalStartDate
        settings.targetDeadline = deadline
        settings.targetDailyBalance = dailyBalance
        settings.targetIntakeCalories = targetIntakeCalories
        settings.hasCompletedInitialSetup = true

        saveSettings()

        print("===== saveDeadlineCourseSettings END =====")
    }

    // MARK: - 符号変換

    func signedBalance(direction: GoalDirection, rawValue: Int) -> Int {
        print("===== signedBalance START =====")
        print("direction = \(direction.rawValue)")
        print("rawValue = \(rawValue)")

        let result: Int

        switch direction {
        case .plus:
            result = rawValue
        case .minus:
            result = -rawValue
        case .maintain:
            result = 0
        }

        print("signed result = \(result)")
        print("===== signedBalance END =====")
        return result
    }
}

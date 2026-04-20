//
//  AppDataStore.swift
//  Yurukaro
//
//  Created by 衛藤唯花 on 2026/04/17.
//

import Foundation
import Combine

/// アプリ全体のデータをまとめて管理するクラス
final class AppDataStore: ObservableObject {

    /// アプリ設定
    @Published var settings: AppSettings {
        didSet {
            saveSettings()
        }
    }

    /// 1日ごとの記録一覧
    @Published var records: [DailyRecord] {
        didSet {
            saveRecords()
        }
    }

    /// UserDefaults に保存するときのキー
    private let settingsKey = "app_settings"
    private let recordsKey = "daily_records"

    /// 初期化
    init() {
        self.settings = AppSettings()
        self.records = []

        loadSettings()
        loadRecords()
    }

    // MARK: - 初期設定の保存・読込

    /// AppSettings を UserDefaults に保存
    func saveSettings() {
        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: settingsKey)
        } catch {
            print("⚠️ AppSettings の保存に失敗しました: \(error)")
        }
    }

    /// AppSettings を UserDefaults から読込
    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: settingsKey) else {
            return
        }

        do {
            let decoded = try JSONDecoder().decode(AppSettings.self, from: data)
            self.settings = decoded
        } catch {
            print("⚠️ AppSettings の読込に失敗しました: \(error)")
        }
    }

    // MARK: - 記録データの保存・読込

    /// DailyRecord 配列を UserDefaults に保存
    private func saveRecords() {
        do {
            let data = try JSONEncoder().encode(records)
            UserDefaults.standard.set(data, forKey: recordsKey)
        } catch {
            print("⚠️ DailyRecord の保存に失敗しました: \(error)")
        }
    }

    /// DailyRecord 配列を UserDefaults から読込
    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: recordsKey) else {
            return
        }

        do {
            let decoded = try JSONDecoder().decode([DailyRecord].self, from: data)
            self.records = decoded
        } catch {
            print("⚠️ DailyRecord の読込に失敗しました: \(error)")
        }
    }

    // MARK: - 今日の記録取得

    /// 指定した日付の記録を返す
    func record(for date: Date) -> DailyRecord? {
        return records.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    /// 今日の記録を返す。なければ新規作成して返す
    func recordForToday() -> DailyRecord {
        let today = Date()

        if let existing = record(for: today) {
            return existing
        } else {
            let newRecord = DailyRecord(
                date: today,
                intakeCalories: 0,
                exerciseCalories: 0,
                maintenanceCalories: settings.maintenanceCalories
            )
            records.append(newRecord)
            sortRecords()
            return newRecord
        }
    }

    // MARK: - 記録の追加 / 更新

    /// 記録を追加または更新する
    func upsertRecord(_ record: DailyRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
        } else {
            records.append(record)
        }

        sortRecords()
    }

    /// 指定日の摂取カロリーを加算
    func addIntakeCalories(_ calories: Int, for date: Date) {
        var targetRecord = record(for: date) ?? DailyRecord(
            date: date,
            intakeCalories: 0,
            exerciseCalories: 0,
            maintenanceCalories: settings.maintenanceCalories
        )

        targetRecord.intakeCalories += calories
        upsertRecord(targetRecord)
    }

    /// 指定日の消費カロリーを加算
    func addExerciseCalories(_ calories: Int, for date: Date) {
        var targetRecord = record(for: date) ?? DailyRecord(
            date: date,
            intakeCalories: 0,
            exerciseCalories: 0,
            maintenanceCalories: settings.maintenanceCalories
        )

        targetRecord.exerciseCalories += calories
        upsertRecord(targetRecord)
    }

    /// 指定日の摂取カロリーを直接上書き
    func updateIntakeCalories(_ calories: Int, for date: Date) {
        var targetRecord = record(for: date) ?? DailyRecord(
            date: date,
            intakeCalories: 0,
            exerciseCalories: 0,
            maintenanceCalories: settings.maintenanceCalories
        )

        targetRecord.intakeCalories = calories
        upsertRecord(targetRecord)
    }

    /// 指定日の消費カロリーを直接上書き
    func updateExerciseCalories(_ calories: Int, for date: Date) {
        var targetRecord = record(for: date) ?? DailyRecord(
            date: date,
            intakeCalories: 0,
            exerciseCalories: 0,
            maintenanceCalories: settings.maintenanceCalories
        )

        targetRecord.exerciseCalories = calories
        upsertRecord(targetRecord)
    }

    /// 指定日のメンテナンスカロリーを更新
    func updateMaintenanceCalories(_ calories: Int, for date: Date) {
        var targetRecord = record(for: date) ?? DailyRecord(
            date: date,
            intakeCalories: 0,
            exerciseCalories: 0,
            maintenanceCalories: settings.maintenanceCalories
        )

        targetRecord.maintenanceCalories = calories
        upsertRecord(targetRecord)
    }

    // MARK: - 初期設定の保存

    /// コース2：毎日同じ目安で管理 の設定を保存
    func saveMaintenanceCourseSettings(
        maintenanceCalories: Int,
        direction: GoalDirection,
        rawBalanceValue: Int
    ) {
        let signedBalance = signedBalance(
            direction: direction,
            rawValue: rawBalanceValue
        )

        settings.maintenanceCalories = maintenanceCalories
        settings.selectedCourse = .maintenance
        settings.goalDirection = direction
        settings.targetDailyBalance = signedBalance
        settings.targetTotalBalance = nil
        settings.goalDurationDays = nil
        settings.targetDeadline = nil
        settings.targetIntakeCalories = maintenanceCalories + signedBalance
        settings.hasCompletedInitialSetup = true
    }

    /// コース選択直後の最低限の保存
    func saveCourseSelectionOnly(
        maintenanceCalories: Int,
        selectedCourse: AppCourse
    ) {
        settings.maintenanceCalories = maintenanceCalories
        settings.selectedCourse = selectedCourse
    }

    // MARK: - 計算補助

    /// 方向と入力値から、計算に使う符号付き収支を返す
    /// 例: plus + 150 -> 150
    ///     minus + 240 -> -240
    ///     maintain -> 0
    func signedBalance(direction: GoalDirection, rawValue: Int) -> Int {
        switch direction {
        case .plus:
            return abs(rawValue)
        case .minus:
            return -abs(rawValue)
        case .maintain:
            return 0
        }
    }

    /// 今日あと何 kcal 食べていいかを返す
    /// 計算式: 目標摂取カロリー - 今日の摂取 + 今日の消費
    func remainingCaloriesForToday(on date: Date = Date()) -> Int? {
        guard let targetIntakeCalories = settings.targetIntakeCalories else {
            return nil
        }

        let todayRecord = record(for: date)
        let intake = todayRecord?.intakeCalories ?? 0
        let exercise = todayRecord?.exerciseCalories ?? 0

        return targetIntakeCalories - intake + exercise
    }

    // MARK: - 月の集計

    /// 指定した月の記録だけ返す
    func records(in month: Date) -> [DailyRecord] {
        let calendar = Calendar.current

        return records.filter { record in
            calendar.isDate(record.date, equalTo: month, toGranularity: .month) &&
            calendar.isDate(record.date, equalTo: month, toGranularity: .year)
        }
    }

    /// 指定した月の累計収支
    func totalBalance(in month: Date) -> Int {
        return records(in: month).reduce(0) { partialResult, record in
            partialResult + record.balance
        }
    }

    // MARK: - 並び替え

    /// 日付順に並び替える
    private func sortRecords() {
        records.sort { $0.date < $1.date }
    }
}

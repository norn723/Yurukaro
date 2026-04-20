//
//  DailyRecord.swift
//  Yurukaro
//
//  Created by 衛藤唯花  on 2026/04/17.
//

import Foundation

/// 1日分のカロリー記録を表すデータモデル
struct DailyRecord: Identifiable, Codable {
    
    /// 一意のID（SwiftUIでリスト表示するときに必要）
    let id: UUID
    
    /// 日付（この記録がいつのものか）
    var date: Date
    
    /// 摂取カロリー（食べた分）
    var intakeCalories: Int
    
    /// 消費カロリー（運動など）
    var exerciseCalories: Int
    
    /// メンテナンスカロリー（基準）
    var maintenanceCalories: Int
    
    /// 初期化
    init(
        id: UUID = UUID(),
        date: Date,
        intakeCalories: Int = 0,
        exerciseCalories: Int = 0,
        maintenanceCalories: Int
    ) {
        self.id = id
        self.date = date
        self.intakeCalories = intakeCalories
        self.exerciseCalories = exerciseCalories
        self.maintenanceCalories = maintenanceCalories
    }
    
    /// 収支（自動計算）
    var balance: Int {
        return intakeCalories - maintenanceCalories - exerciseCalories
    }
}

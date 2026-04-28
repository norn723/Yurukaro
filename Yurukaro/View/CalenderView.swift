import SwiftUI

struct CalendarView: View {

    @EnvironmentObject var appDataStore: AppDataStore

    /// 表示中の月
    @State private var displayedMonth: Date = Date()

    /// 選択中の日付
    @State private var selectedDate: Date = Date()

    /// 入力画面モーダル
    @State private var showRecordInputSheet: Bool = false

    private var theme: AppTheme {
        AppTheme.theme(for: appDataStore.settings.selectedTheme)
    }

    /// 曜日表示
    private let weekdaySymbols: [String] = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    headerSection
                    monthHeaderSection
                    weekdayHeaderSection
                    calendarGridSection
                    selectedDateDetailSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 140)
            }
        }
        .sheet(isPresented: $showRecordInputSheet) {
            RecordInputView(targetDate: selectedDate)
                .environmentObject(appDataStore)
        }
        .onAppear {
            print("===== CalendarView onAppear START =====")
            displayedMonth = startOfMonth(for: Date())
            selectedDate = Date()
            print("displayedMonth = \(displayedMonth)")
            print("selectedDate = \(selectedDate)")
            print("maintenanceCalories = \(appDataStore.settings.maintenanceCalories)")
            print("dailyRecords.count = \(appDataStore.dailyRecords.count)")
            print("===== CalendarView onAppear END =====")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("カレンダー")
                .font(.system(size: 30, weight: .bold))

            Text("日付をタップすると、その日の記録を確認できるよ")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Month Header

    private var monthHeaderSection: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(theme.card)
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Text(monthTitle(for: displayedMonth))
                .font(.system(size: 22, weight: .bold))

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(theme.card)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Weekday Header

    private var weekdayHeaderSection: some View {
        HStack(spacing: 8) {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { index, symbol in
                Text(symbol)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(colorForWeekdayIndex(index))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Calendar Grid

    private var calendarGridSection: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(calendarDays(), id: \.self) { optionalDate in
                if let date = optionalDate {
                    dayCell(for: date)
                } else {
                    emptyDayCell
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(date)
        let isInDisplayedMonth = Calendar.current.isDate(date, equalTo: displayedMonth, toGranularity: .month)
        let record = appDataStore.record(for: date)

        return Button {
            print("===== Calendar day tapped START =====")
            selectedDate = date
            print("selectedDate = \(selectedDate)")

            if let record {
                print("record exists")
                print("intake = \(record.intakeCalories)")
                print("exercise = \(record.exerciseCalories)")
                print("maintenance = \(appDataStore.settings.maintenanceCalories)")
                print("balance = \(balanceValue(intake: record.intakeCalories, exercise: record.exerciseCalories))")
            } else {
                print("record not found")
            }

            print("===== Calendar day tapped END =====")
        } label: {
            VStack(spacing: 5) {
                Text(dayNumberText(for: date))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(
                        isToday
                        ? theme.accentDark
                        : (isInDisplayedMonth ? .primary : .secondary)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: true, vertical: false)

                Spacer(minLength: 0)

                if let record {
                    Text(compactCaloriesText(record.intakeCalories))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(theme.accentDark)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(" ")
                        .font(.system(size: 10, weight: .bold))
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 8)
            .padding(.horizontal, 4)
            .frame(height: 82)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? theme.accent.opacity(0.24) : theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected
                        ? theme.accentDark
                        : (isToday ? theme.accent.opacity(0.55) : Color.clear),
                        lineWidth: isSelected ? 2 : 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(isInDisplayedMonth ? 1.0 : 0.45)
    }

    private var emptyDayCell: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.clear)
            .frame(height: 82)
    }

    // MARK: - Selected Date Detail

    private var selectedDateDetailSection: some View {
        let record = appDataStore.record(for: selectedDate)
        let intake = record?.intakeCalories ?? 0
        let exercise = record?.exerciseCalories ?? 0
        let maintenance = appDataStore.settings.maintenanceCalories
        let balance = balanceValue(intake: intake, exercise: exercise)

        return VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedDateTitle(for: selectedDate))
                        .font(.system(size: 22, weight: .bold))

                    Text(record == nil ? "まだ記録なし" : "記録あり")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    print("===== Calendar edit button tapped START =====")
                    print("selectedDate = \(selectedDate)")
                    showRecordInputSheet = true
                    print("showRecordInputSheet = true")
                    print("===== Calendar edit button tapped END =====")
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("編集")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(theme.accent)
                    )
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 12) {
                detailRow(title: "摂取", value: "\(intake) kcal")
                detailRow(title: "消費", value: "\(exercise) kcal")
                detailRow(title: "メンテナンス", value: "\(maintenance) kcal")
                detailRow(title: "収支", value: balanceText(balance))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.card)
        )
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 18, weight: .bold))
        }
        .padding(.vertical, 2)
    }

    // MARK: - Date Helpers

    private func moveMonth(by value: Int) {
        print("===== moveMonth START =====")
        print("current displayedMonth = \(displayedMonth)")

        if let moved = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = startOfMonth(for: moved)
            print("new displayedMonth = \(displayedMonth)")
        }

        print("===== moveMonth END =====")
    }

    private func startOfMonth(for date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return Calendar.current.date(from: components) ?? date
    }

    private func calendarDays() -> [Date?] {
        print("===== calendarDays START =====")

        let calendar = Calendar.current
        let startOfDisplayedMonth = startOfMonth(for: displayedMonth)

        guard let dayRange = calendar.range(of: .day, in: .month, for: startOfDisplayedMonth) else {
            print("ERROR: dayRange 取得失敗")
            print("===== calendarDays END =====")
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: startOfDisplayedMonth)
        let leadingEmptyCount = firstWeekday - 1

        print("displayedMonth = \(displayedMonth)")
        print("firstWeekday = \(firstWeekday)")
        print("leadingEmptyCount = \(leadingEmptyCount)")
        print("daysInMonth = \(dayRange.count)")

        var days: [Date?] = Array(repeating: nil, count: leadingEmptyCount)

        for day in dayRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfDisplayedMonth) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        print("calendarDays total count = \(days.count)")
        print("===== calendarDays END =====")

        return days
    }

    private func dayNumberText(for date: Date) -> String {
        String(Calendar.current.component(.day, from: date))
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: date)
    }

    private func selectedDateTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }

    /// 正しいカロリー収支
    /// 摂取 - 消費 - メンテナンスカロリー
    private func balanceValue(intake: Int, exercise: Int) -> Int {
        intake - exercise - appDataStore.settings.maintenanceCalories
    }

    private func balanceText(_ value: Int) -> String {
        value >= 0 ? "+\(value) kcal" : "\(value) kcal"
    }

    private func compactCaloriesText(_ value: Int) -> String {
        if value >= 10000 {
            return "\(value / 1000)k"
        } else if value >= 1000 {
            let doubleValue = Double(value) / 1000.0
            return String(format: "%.1fk", doubleValue)
        } else {
            return "\(value)"
        }
    }

    private func colorForWeekdayIndex(_ index: Int) -> Color {
        if index == 0 {
            return .red.opacity(0.8)
        } else if index == 6 {
            return .blue.opacity(0.8)
        } else {
            return .secondary
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(AppDataStore())
}

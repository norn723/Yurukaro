import SwiftUI

struct RecordInputView: View {

    @EnvironmentObject var appDataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let targetDate: Date

    init(targetDate: Date = Date()) {
        self.targetDate = targetDate
    }

    @State private var baseIntakeCalories: Int = 0
    @State private var baseExerciseCalories: Int = 0

    @State private var calculatorExpression: String = ""
    @State private var calculatorResultText: String = "0"

    enum InputMode {
        case intake
        case exercise
    }

    enum ReflectMode {
        case add
        case subtract
    }

    @State private var selectedMode: InputMode = .intake
    @State private var selectedReflectMode: ReflectMode = .add
    @State private var isCalculatorPresented: Bool = false

    @State private var displayedHistoryEntries: [RecordHistoryEntry] = []

    private var theme: AppTheme {
        AppTheme.theme(for: appDataStore.settings.selectedTheme)
    }

    private let softGray = Color(red: 0.94, green: 0.94, blue: 0.95)
    private let softPink = Color(red: 0.98, green: 0.82, blue: 0.86)
    private let softBlue = Color(red: 0.79, green: 0.88, blue: 0.98)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                theme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            headerSection
                            guideSection
                            statusSection
                            calculatorDisplaySection
                            saveButtonSection
                            historySection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    }
                    .frame(height: topAreaHeight(totalHeight: geometry.size.height))
                    .clipped()

                    Spacer(minLength: 0)
                }

                if isCalculatorPresented {
                    VStack(spacing: 10) {
                        HStack {
                            Text(selectedMode == .intake ? "摂取入力中" : "消費入力中")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.secondary)

                            Spacer()

                            Button {
                                print("===== 電卓を閉じる START =====")
                                isCalculatorPresented = false
                                resetCalculatorForCurrentMode()
                                print("isCalculatorPresented = false")
                                print("===== 電卓を閉じる END =====")
                            } label: {
                                Text("閉じる")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(theme.accentDark)
                            }
                            .buttonStyle(.plain)
                        }

                        reflectModePickerSection
                        calculatorPadSection
                        reflectButtonSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 14)
                    .frame(maxWidth: .infinity)
                    .frame(height: calculatorAreaHeight(totalHeight: geometry.size.height))
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.94))
                            .ignoresSafeArea(edges: .bottom)
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.easeInOut(duration: 0.22), value: isCalculatorPresented)
        }
        .onAppear {
            print("===== RecordInputView onAppear START =====")
            print("targetDate = \(targetDate)")
            setupInitialValues()
            loadDisplayedHistoryEntries()
            resetCalculatorForCurrentMode()
            selectedReflectMode = .add
            isCalculatorPresented = false
            print("selectedReflectMode = add")
            print("isCalculatorPresented = false")
            print("===== RecordInputView onAppear END =====")
        }
    }

    // MARK: - Layout

    private func topAreaHeight(totalHeight: CGFloat) -> CGFloat {
        let height = isCalculatorPresented ? totalHeight * 0.52 : totalHeight
        print("topAreaHeight = \(height)")
        return height
    }

    private func calculatorAreaHeight(totalHeight: CGFloat) -> CGFloat {
        let height = totalHeight * 0.48
        print("calculatorAreaHeight = \(height)")
        return height
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("記録入力")
                .font(.system(size: 30, weight: .bold))

            Text(targetDateTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                modeButton(
                    title: "摂取",
                    isSelected: selectedMode == .intake
                ) {
                    switchMode(to: .intake)
                }

                modeButton(
                    title: "消費",
                    isSelected: selectedMode == .exercise
                ) {
                    switchMode(to: .exercise)
                }
            }
        }
    }

    private func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(isSelected ? theme.accent : Color.white.opacity(0.88))
                )
                .foregroundStyle(isSelected ? Color.white : Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.18), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var guideSection: some View {
        HStack {
            Text(
                isCalculatorPresented
                ? "下の電卓で計算して、加算か減算を選んでから「反映する」を押してね"
                : "「摂取」または「消費」のカードを押すと入力を始められるよ"
            )
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Status

    private var statusSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                tappableInfoCard(
                    title: dateLabelPrefix + "摂取",
                    value: "\(baseIntakeCalories) kcal",
                    subtitle: isCalculatorPresented && selectedMode == .intake ? "入力中" : "タップで入力",
                    isHighlighted: isCalculatorPresented && selectedMode == .intake
                ) {
                    openCalculator(for: .intake)
                }

                tappableInfoCard(
                    title: dateLabelPrefix + "消費",
                    value: "\(baseExerciseCalories) kcal",
                    subtitle: isCalculatorPresented && selectedMode == .exercise ? "入力中" : "タップで入力",
                    isHighlighted: isCalculatorPresented && selectedMode == .exercise
                ) {
                    openCalculator(for: .exercise)
                }
            }
        }
    }

    private func tappableInfoCard(
        title: String,
        value: String,
        subtitle: String,
        isHighlighted: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isHighlighted ? theme.accentDark : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Calculator Display

    private var calculatorDisplaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(calculatorDisplayTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text(calculatorExpression.isEmpty ? "0" : calculatorExpression)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(calculatorExpression.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                HStack {
                    Text("=")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(theme.accentDark)

                    Text(calculatorResultText)
                        .font(.system(size: 34, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.98))
            )
        }
        .opacity(isCalculatorPresented ? 1.0 : 0.55)
    }

    // MARK: - Save Button

    private var saveButtonSection: some View {
        Button {
            saveRecord()
        } label: {
            Text("保存")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(theme.accent)
                )
                .foregroundStyle(.white)
                .shadow(color: theme.accent.opacity(0.25), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("この日の反映履歴")
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                if !displayedHistoryEntries.isEmpty {
                    Text("\(displayedHistoryEntries.count)件")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }

            if displayedHistoryEntries.isEmpty {
                Text("まだ反映履歴はありません")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.92))
                    )
            } else {
                VStack(spacing: 10) {
                    ForEach(displayedHistoryEntries) { entry in
                        historyRow(entry: entry)
                    }
                }
            }
        }
    }

    private func historyRow(entry: RecordHistoryEntry) -> some View {
        HStack(spacing: 12) {
            Text(historyTimeText(for: entry.createdAt))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 76, alignment: .leading)

            Text(entry.type.displayTitle)
                .font(.system(size: 14, weight: .bold))
                .frame(width: 42, alignment: .leading)

            Text(entry.calories >= 0 ? "加算" : "減算")
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(entry.calories >= 0 ? softPink : softBlue)
                )

            Spacer()

            Text(historyCaloriesText(for: entry.calories))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(entry.calories >= 0 ? Color.pink.opacity(0.85) : Color.blue.opacity(0.85))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.96))
        )
    }

    // MARK: - Reflect Mode Picker

    private var reflectModePickerSection: some View {
        HStack(spacing: 10) {
            reflectModeButton(
                title: "加算",
                isSelected: selectedReflectMode == .add,
                selectedColor: softPink
            ) {
                print("===== reflectModeButton add tapped START =====")
                selectedReflectMode = .add
                print("selectedReflectMode = add")
                print("===== reflectModeButton add tapped END =====")
            }

            reflectModeButton(
                title: "減算",
                isSelected: selectedReflectMode == .subtract,
                selectedColor: softBlue
            ) {
                print("===== reflectModeButton subtract tapped START =====")
                selectedReflectMode = .subtract
                print("selectedReflectMode = subtract")
                print("===== reflectModeButton subtract tapped END =====")
            }
        }
    }

    private func reflectModeButton(
        title: String,
        isSelected: Bool,
        selectedColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? selectedColor : softGray.opacity(0.9))
                )
                .foregroundStyle(.black.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.12), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Calculator Pad

    private var calculatorPadSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                calculatorButton(title: "1", style: .number) { appendToExpression("1") }
                calculatorButton(title: "2", style: .number) { appendToExpression("2") }
                calculatorButton(title: "3", style: .number) { appendToExpression("3") }
                calculatorButton(title: "-", style: .operatorButton) { appendOperator("-") }
            }

            HStack(spacing: 8) {
                calculatorButton(title: "4", style: .number) { appendToExpression("4") }
                calculatorButton(title: "5", style: .number) { appendToExpression("5") }
                calculatorButton(title: "6", style: .number) { appendToExpression("6") }
                calculatorButton(title: "+", style: .operatorButton) { appendOperator("+") }
            }

            HStack(spacing: 8) {
                calculatorButton(title: "7", style: .number) { appendToExpression("7") }
                calculatorButton(title: "8", style: .number) { appendToExpression("8") }
                calculatorButton(title: "9", style: .number) { appendToExpression("9") }
                calculatorButton(title: "×", style: .operatorButton) { appendOperator("*") }
            }

            HStack(spacing: 8) {
                calculatorButton(title: "C", style: .subtleAction) { clearAll() }
                calculatorButton(title: "0", style: .number) { appendToExpression("0") }
                calculatorButton(title: "⌫", style: .subtleAction) { deleteLastCharacter() }
                calculatorButton(title: "=", style: .equalButton) { calculateExpression() }
            }
        }
    }

    private var reflectButtonSection: some View {
        Button {
            reflectCalculatedValue()
        } label: {
            Text(reflectButtonTitle)
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(theme.accentDark)
                )
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    private enum CalculatorButtonStyle {
        case number
        case operatorButton
        case equalButton
        case subtleAction
    }

    private func calculatorButton(title: String, style: CalculatorButtonStyle, action: @escaping () -> Void) -> some View {
        let backgroundColor: Color
        let foregroundColor: Color

        switch style {
        case .number:
            backgroundColor = Color.white
            foregroundColor = .black
        case .operatorButton:
            backgroundColor = softGray
            foregroundColor = .black
        case .equalButton:
            backgroundColor = theme.accentDark
            foregroundColor = .white
        case .subtleAction:
            backgroundColor = Color.white
            foregroundColor = theme.accentDark
        }

        return Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(backgroundColor)
                )
                .foregroundStyle(foregroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Setup

    private func setupInitialValues() {
        print("===== setupInitialValues START =====")
        print("targetDate = \(targetDate)")

        if let existingRecord = appDataStore.record(for: targetDate) {
            baseIntakeCalories = existingRecord.intakeCalories
            baseExerciseCalories = existingRecord.exerciseCalories
            print("既存記録あり")
        } else {
            baseIntakeCalories = 0
            baseExerciseCalories = 0
            print("既存記録なし -> 0 で開始")
        }

        print("baseIntakeCalories = \(baseIntakeCalories)")
        print("baseExerciseCalories = \(baseExerciseCalories)")
        print("===== setupInitialValues END =====")
    }

    private func loadDisplayedHistoryEntries() {
        print("===== loadDisplayedHistoryEntries START =====")
        displayedHistoryEntries = appDataStore.historyEntries(for: targetDate)
        print("displayedHistoryEntries.count = \(displayedHistoryEntries.count)")
        print("===== loadDisplayedHistoryEntries END =====")
    }

    // MARK: - Mode

    private func openCalculator(for mode: InputMode) {
        print("===== openCalculator START =====")
        print("selected mode = \(mode == .intake ? "intake" : "exercise")")

        selectedMode = mode
        selectedReflectMode = .add
        resetCalculatorForCurrentMode()
        isCalculatorPresented = true

        print("selectedReflectMode reset to add")
        print("isCalculatorPresented = true")
        print("===== openCalculator END =====")
    }

    private func switchMode(to newMode: InputMode) {
        print("===== switchMode START =====")
        print("currentMode = \(selectedMode == .intake ? "intake" : "exercise")")
        print("newMode = \(newMode == .intake ? "intake" : "exercise")")

        selectedMode = newMode
        selectedReflectMode = .add

        if isCalculatorPresented {
            resetCalculatorForCurrentMode()
            print("calculator is open, expression reset")
        } else {
            print("calculator is closed, only mode switched")
        }

        print("selectedReflectMode reset to add")
        print("===== switchMode END =====")
    }

    private func resetCalculatorForCurrentMode() {
        print("===== resetCalculatorForCurrentMode START =====")
        calculatorExpression = ""
        calculatorResultText = "0"
        print("calculatorExpression cleared")
        print("calculatorResultText reset to 0")
        print("===== resetCalculatorForCurrentMode END =====")
    }

    // MARK: - Calculator Input

    private func appendToExpression(_ value: String) {
        print("===== appendToExpression START =====")
        print("append value = \(value)")
        print("before expression = \(calculatorExpression)")

        calculatorExpression += value
        updatePreviewResultWithoutForcingEqual()

        print("after expression = \(calculatorExpression)")
        print("after result = \(calculatorResultText)")
        print("===== appendToExpression END =====")
    }

    private func appendOperator(_ op: String) {
        print("===== appendOperator START =====")
        print("operator = \(op)")
        print("before expression = \(calculatorExpression)")

        guard !calculatorExpression.isEmpty else {
            print("expression is empty. operator ignored.")
            print("===== appendOperator END =====")
            return
        }

        guard let lastCharacter = calculatorExpression.last else {
            print("lastCharacter not found. operator ignored.")
            print("===== appendOperator END =====")
            return
        }

        let operatorSet: Set<Character> = ["+", "-", "*"]

        if operatorSet.contains(lastCharacter) {
            calculatorExpression.removeLast()
            calculatorExpression += op
            print("last operator replaced")
        } else {
            calculatorExpression += op
            print("operator appended")
        }

        print("after expression = \(calculatorExpression)")
        print("===== appendOperator END =====")
    }

    private func clearAll() {
        print("===== clearAll START =====")
        calculatorExpression = ""
        calculatorResultText = "0"
        print("expression cleared")
        print("result reset")
        print("===== clearAll END =====")
    }

    private func deleteLastCharacter() {
        print("===== deleteLastCharacter START =====")
        print("before expression = \(calculatorExpression)")

        guard !calculatorExpression.isEmpty else {
            print("expression already empty")
            print("===== deleteLastCharacter END =====")
            return
        }

        calculatorExpression.removeLast()
        updatePreviewResultWithoutForcingEqual()

        print("after expression = \(calculatorExpression)")
        print("after result = \(calculatorResultText)")
        print("===== deleteLastCharacter END =====")
    }

    private func calculateExpression() {
        print("===== calculateExpression START =====")
        let calculatedValue = evaluatedCalculatorValue()
        calculatorResultText = "\(calculatedValue)"
        print("expression = \(calculatorExpression)")
        print("result = \(calculatorResultText)")
        print("===== calculateExpression END =====")
    }

    private func updatePreviewResultWithoutForcingEqual() {
        let calculatedValue = evaluatedCalculatorValue()
        calculatorResultText = "\(calculatedValue)"
    }

    private func evaluatedCalculatorValue() -> Int {
        print("===== evaluatedCalculatorValue START =====")
        print("expression = \(calculatorExpression)")

        guard !calculatorExpression.isEmpty else {
            print("expression empty -> return 0")
            print("===== evaluatedCalculatorValue END =====")
            return 0
        }

        var safeExpression = calculatorExpression

        while let lastCharacter = safeExpression.last,
              ["+", "-", "*"].contains(lastCharacter) {
            safeExpression.removeLast()
            print("trailing operator removed. safeExpression = \(safeExpression)")
        }

        guard !safeExpression.isEmpty else {
            print("safeExpression empty -> return 0")
            print("===== evaluatedCalculatorValue END =====")
            return 0
        }

        let result = evaluateSimpleExpression(safeExpression)

        print("evaluated result = \(result)")
        print("===== evaluatedCalculatorValue END =====")
        return result
    }

    private func evaluateSimpleExpression(_ expression: String) -> Int {
        print("===== evaluateSimpleExpression START =====")
        print("expression = \(expression)")

        var numbers: [Int] = []
        var operators: [Character] = []
        var currentNumberText = ""

        for character in expression {
            if character.isNumber {
                currentNumberText.append(character)
            } else if character == "+" || character == "-" || character == "*" {
                guard let number = Int(currentNumberText) else {
                    print("number parse failed -> return 0")
                    print("===== evaluateSimpleExpression END =====")
                    return 0
                }

                numbers.append(number)
                operators.append(character)
                currentNumberText = ""
            } else {
                print("unsupported character found -> return 0")
                print("===== evaluateSimpleExpression END =====")
                return 0
            }
        }

        guard let lastNumber = Int(currentNumberText) else {
            print("last number parse failed -> return 0")
            print("===== evaluateSimpleExpression END =====")
            return 0
        }

        numbers.append(lastNumber)

        guard !numbers.isEmpty else {
            print("numbers empty -> return 0")
            print("===== evaluateSimpleExpression END =====")
            return 0
        }

        var processedNumbers: [Int] = [numbers[0]]
        var processedOperators: [Character] = []

        for index in 0..<operators.count {
            let currentOperator = operators[index]
            let nextNumber = numbers[index + 1]

            if currentOperator == "*" {
                let previousNumber = processedNumbers.removeLast()
                processedNumbers.append(previousNumber * nextNumber)
            } else {
                processedOperators.append(currentOperator)
                processedNumbers.append(nextNumber)
            }
        }

        var result = processedNumbers[0]

        for index in 0..<processedOperators.count {
            let currentOperator = processedOperators[index]
            let nextNumber = processedNumbers[index + 1]

            if currentOperator == "+" {
                result += nextNumber
            } else if currentOperator == "-" {
                result -= nextNumber
            }
        }

        print("result = \(result)")
        print("===== evaluateSimpleExpression END =====")
        return result
    }

    // MARK: - Reflect

    private func reflectCalculatedValue() {
        print("===== reflectCalculatedValue START =====")
        print("selectedMode = \(selectedMode == .intake ? "intake" : "exercise")")
        print("selectedReflectMode = \(selectedReflectMode == .add ? "add" : "subtract")")
        print("calculatorExpression = \(calculatorExpression)")
        print("pendingCalculatedValue = \(pendingCalculatedValue)")

        let value = pendingCalculatedValue

        guard value != 0 else {
            print("pendingCalculatedValue is 0, nothing reflected")
            print("===== reflectCalculatedValue END =====")
            return
        }

        let signedValue: Int = selectedReflectMode == .add ? value : -value

        switch selectedMode {
        case .intake:
            baseIntakeCalories = max(0, baseIntakeCalories + signedValue)
            print("baseIntakeCalories updated = \(baseIntakeCalories)")

        case .exercise:
            baseExerciseCalories = max(0, baseExerciseCalories + signedValue)
            print("baseExerciseCalories updated = \(baseExerciseCalories)")
        }

        let historyType: RecordHistoryEntry.EntryType = selectedMode == .intake ? .intake : .exercise

        let entry = RecordHistoryEntry(
            targetDate: targetDate,
            createdAt: Date(),
            type: historyType,
            calories: signedValue
        )

        appDataStore.addHistoryEntry(entry)
        loadDisplayedHistoryEntries()

        resetCalculatorForCurrentMode()

        print("===== reflectCalculatedValue END =====")
    }

    // MARK: - Calculated Values

    private var pendingCalculatedValue: Int {
        evaluatedCalculatorValue()
    }

    private var calculatorDisplayTitle: String {
        switch selectedMode {
        case .intake:
            return selectedReflectMode == .add ? "摂取に加算する値" : "摂取から減算する値"
        case .exercise:
            return selectedReflectMode == .add ? "消費に加算する値" : "消費から減算する値"
        }
    }

    private var reflectButtonTitle: String {
        switch selectedReflectMode {
        case .add:
            return "加算で反映する"
        case .subtract:
            return "減算で反映する"
        }
    }

    // MARK: - Save

    private func saveRecord() {
        print("===== saveRecord START =====")
        print("targetDate = \(targetDate)")
        print("baseIntakeCalories = \(baseIntakeCalories)")
        print("baseExerciseCalories = \(baseExerciseCalories)")
        print("calculatorExpression = \(calculatorExpression)")
        print("calculatorResultText = \(calculatorResultText)")
        print("displayedHistoryEntries.count = \(displayedHistoryEntries.count)")
        print("保存は反映済みの値だけを使う")

        let newRecord = DailyRecord(
            date: targetDate,
            intakeCalories: baseIntakeCalories,
            exerciseCalories: baseExerciseCalories,
            maintenanceCalories: appDataStore.settings.maintenanceCalories ?? 0
        )

        appDataStore.upsertRecord(newRecord)

        print("record saved")
        print("dismiss RecordInputView")
        print("===== saveRecord END =====")

        dismiss()
    }

    // MARK: - Text Helpers

    private var targetDateTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日の記録"
        return formatter.string(from: targetDate)
    }

    private var dateLabelPrefix: String {
        Calendar.current.isDateInToday(targetDate) ? "今日の" : "この日の"
    }

    private func historyTimeText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d HH:mm"
        return formatter.string(from: date)
    }

    private func historyCaloriesText(for calories: Int) -> String {
        calories >= 0 ? "+\(calories) kcal" : "\(calories) kcal"
    }
}

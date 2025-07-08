import UIKit

// MARK: - Keyboard Layout Enums
enum KeyboardMode {
    case letters
    case numbers
    case symbols
    case islamic
}



// MARK: - Key Types
enum KeyType {
    case letter(String)
    case number(String)
    case symbol(String)
    case space
    case delete
    case shift
    case returnKey
    case numbers
    case symbols
    case globe
    case moon
    case islamicPhrase(String)
    case islamicDua(String)
    case islamicToggle
}

class KeyboardViewController: UIInputViewController {
    
    // MARK: - Properties
    private var keyboardView: UIView!
    private var currentMode: KeyboardMode = .letters
    private var currentLanguage: KeyboardLanguage = .english
    private var isShiftPressed = false
    private var isCapsLockOn = false
    
    private let languageManager = KeyboardLanguageManager.shared
    private let phrasesManager = KeyboardPhrasesManager.shared
    private let duaManager = KeyboardDuaManager.shared
    private let colorManager = KeyboardColorManager.shared
    
    private let keyboardHeight: CGFloat = 216 // Стандартная высота iOS клавиатуры
    private let keyHeight: CGFloat = 42
    private let keySpacing: CGFloat = 6
    private let rowSpacing: CGFloat = 10
    private let sideMargin: CGFloat = 3
    
    // MARK: - Lifecycle
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let heightConstraint = NSLayoutConstraint(
            item: self.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0.0,
            constant: keyboardHeight
        )
        heightConstraint.priority = UILayoutPriority(999)
        self.view.addConstraint(heightConstraint)
    }
    
    // MARK: - Keyboard Layouts
    private func getLetterLayout() -> [[KeyType]] {
        switch currentLanguage {
        case .english:
            return [
                [.letter("Q"), .letter("W"), .letter("E"), .letter("R"), .letter("T"), .letter("Y"), .letter("U"), .letter("I"), .letter("O"), .letter("P")],
                [.letter("A"), .letter("S"), .letter("D"), .letter("F"), .letter("G"), .letter("H"), .letter("J"), .letter("K"), .letter("L")],
                [.shift, .letter("Z"), .letter("X"), .letter("C"), .letter("V"), .letter("B"), .letter("N"), .letter("M"), .delete],
                [.numbers, .moon, .space, .returnKey]
            ]
        case .russian:
            return [
                [.letter("Й"), .letter("Ц"), .letter("У"), .letter("К"), .letter("Е"), .letter("Н"), .letter("Г"), .letter("Ш"), .letter("Щ"), .letter("З")],
                [.letter("Ф"), .letter("Ы"), .letter("В"), .letter("А"), .letter("П"), .letter("Р"), .letter("О"), .letter("Л"), .letter("Д")],
                [.shift, .letter("Я"), .letter("Ч"), .letter("С"), .letter("М"), .letter("И"), .letter("Т"), .letter("Ь"), .delete],
                [.numbers, .moon, .space, .returnKey]
            ]
        case .kazakh:
            return [
                [.letter("Й"), .letter("Ц"), .letter("У"), .letter("К"), .letter("Е"), .letter("Н"), .letter("Г"), .letter("Ш"), .letter("Щ"), .letter("З")],
                [.letter("Ф"), .letter("Ы"), .letter("В"), .letter("А"), .letter("П"), .letter("Р"), .letter("О"), .letter("Л"), .letter("Д")],
                [.shift, .letter("Я"), .letter("Ч"), .letter("С"), .letter("М"), .letter("И"), .letter("Т"), .letter("Ь"), .delete],
                [.numbers, .moon, .space, .returnKey]
            ]
        case .arabic:
            return [
                [.letter("ض"), .letter("ص"), .letter("ث"), .letter("ق"), .letter("ف"), .letter("غ"), .letter("ع"), .letter("ه"), .letter("خ"), .letter("ح")],
                [.letter("ش"), .letter("س"), .letter("ي"), .letter("ب"), .letter("ل"), .letter("ا"), .letter("ت"), .letter("ن"), .letter("م")],
                [.shift, .letter("ظ"), .letter("ط"), .letter("ذ"), .letter("د"), .letter("ز"), .letter("ر"), .letter("و"), .delete],
                [.numbers, .moon, .space, .returnKey]
            ]
        }
    }
    
    private func getNumberLayout() -> [[KeyType]] {
        return [
            [.number("1"), .number("2"), .number("3"), .number("4"), .number("5"), .number("6"), .number("7"), .number("8"), .number("9"), .number("0")],
            [.symbol("-"), .symbol("/"), .symbol(":"), .symbol(";"), .symbol("("), .symbol(")"), .symbol("$"), .symbol("&"), .symbol("@"), .symbol("\"")],
            [.symbols, .symbol("."), .symbol(","), .symbol("?"), .symbol("!"), .symbol("'"), .delete],
            [.letter("ABC"), .moon, .space, .returnKey]
        ]
    }
    
    private func getSymbolLayout() -> [[KeyType]] {
        return [
            [.symbol("["), .symbol("]"), .symbol("{"), .symbol("}"), .symbol("#"), .symbol("%"), .symbol("^"), .symbol("*"), .symbol("+"), .symbol("=")],
            [.symbol("_"), .symbol("\\"), .symbol("|"), .symbol("~"), .symbol("<"), .symbol(">"), .symbol("€"), .symbol("£"), .symbol("¥")],
            [.numbers, .symbol("•"), .symbol("°"), .symbol("…"), .symbol("¿"), .symbol("¡"), .symbol("§"), .delete],
            [.letter("ABC"), .moon, .space, .returnKey]
        ]
    }
    
    // Новые свойства для управления режимом исламской клавиатуры
    private var islamicMode: IslamicKeyboardMode = .phrases
    private var scrollOffset: CGFloat = 0
    private var lastInsertedText: String?

    private enum IslamicKeyboardMode {
        case phrases
        case duas
    }

    private func getIslamicLayout() -> [[KeyType]] {
        // Создаем прокручиваемую область для фраз/дуа
        return [
            // Нижний ряд с управляющими кнопками
            [.letter("ABC"), .islamicToggle, .globe, .space, .symbol("ﷺ"), .delete, .returnKey]
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Отладка ресурсов (только один раз)
        #if DEBUG
        debugResourceLoading()
        #endif

        // Синхронизируем язык с languageManager
        languageManager.refreshLanguageFromMainApp()
        currentLanguage = languageManager.currentLanguage

        setupKeyboard()

        // Добавляем наблюдатель для изменений цвета
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(colorThemeChanged),
            name: NSNotification.Name("KeyboardColorChanged"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Синхронизируем язык с настройками
        languageManager.refreshLanguageFromMainApp()
        currentLanguage = languageManager.currentLanguage

        // Принудительно обновляем тему при каждом появлении клавиатуры
        colorManager.reloadThemeFromUserDefaults()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.refreshKeyboardData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateAppearance()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        updateAppearance()
    }
    
    // MARK: - Setup Methods
    private func setupKeyboard() {
        view.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0) // Светло-серый фон как у iOS клавиатуры
        
        // Удаляем старые subviews если есть
        view.subviews.forEach { $0.removeFromSuperview() }
        
        createKeyboardView()
    }
    
    private func createKeyboardView() {
        keyboardView = UIView()
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.backgroundColor = .clear
        view.addSubview(keyboardView)

        NSLayoutConstraint.activate([
            keyboardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sideMargin),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sideMargin),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        if currentMode == .islamic {
            createIslamicKeyboard()
        } else {
            createKeyRows()
        }
    }

    private func createIslamicKeyboard() {
        // Принудительно обновляем цветовую тему
        colorManager.reloadThemeFromUserDefaults()

        // Удаляем старые элементы
        keyboardView.subviews.forEach { $0.removeFromSuperview() }

        // Создаем прокручиваемую область для фраз/дуа
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        keyboardView.addSubview(scrollView)

        // Создаем контейнер для кнопок фраз/дуа
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Создаем нижний ряд с управляющими кнопками
        let controlRow = createControlRow()
        keyboardView.addSubview(controlRow)

        // Настраиваем ограничения
        NSLayoutConstraint.activate([
            // ScrollView занимает верхнюю часть
            scrollView.topAnchor.constraint(equalTo: keyboardView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: controlRow.topAnchor, constant: -rowSpacing),

            // ContentView внутри ScrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Нижний ряд управления
            controlRow.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor),
            controlRow.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor),
            controlRow.bottomAnchor.constraint(equalTo: keyboardView.bottomAnchor),
            controlRow.heightAnchor.constraint(equalToConstant: keyHeight)
        ])

        // Заполняем контент
        populateIslamicContent(in: contentView)
    }

    private func createControlRow() -> UIView {
        let controlRow = UIView()
        controlRow.translatesAutoresizingMaskIntoConstraints = false

        // Создаем кнопки управления
        let abcButton = createKeyButton(for: .letter("ABC"), rowIndex: 0, keyIndex: 0)
        let toggleButton = createKeyButton(for: .islamicToggle, rowIndex: 0, keyIndex: 1)
        let spaceButton = createKeyButton(for: .space, rowIndex: 0, keyIndex: 3)
        let sallaButton = createKeyButton(for: .symbol("ﷺ"), rowIndex: 0, keyIndex: 4)
        let deleteButton = createKeyButton(for: .delete, rowIndex: 0, keyIndex: 5)
        let returnButton = createKeyButton(for: .returnKey, rowIndex: 0, keyIndex: 6)

        controlRow.addSubview(abcButton)
        controlRow.addSubview(toggleButton)
        controlRow.addSubview(spaceButton)
        controlRow.addSubview(sallaButton)
        controlRow.addSubview(deleteButton)
        controlRow.addSubview(returnButton)

        // Добавляем кнопку языка только если доступно больше одного языка
        var languageButton: UIButton?
        if languageManager.shouldShowLanguageToggle {
            languageButton = createKeyButton(for: .globe, rowIndex: 0, keyIndex: 2)
            controlRow.addSubview(languageButton!)
        }

        // Настраиваем ограничения
        var constraints: [NSLayoutConstraint] = []

        // Высота кнопок
        constraints.append(contentsOf: [
            abcButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
            toggleButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
            spaceButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
            sallaButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
            deleteButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
            returnButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor)
        ])

        // Вертикальное выравнивание
        constraints.append(contentsOf: [
            abcButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
            toggleButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
            spaceButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
            sallaButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
            deleteButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
            returnButton.topAnchor.constraint(equalTo: controlRow.topAnchor)
        ])

        // Горизонтальное расположение
        constraints.append(contentsOf: [
            abcButton.leadingAnchor.constraint(equalTo: controlRow.leadingAnchor),
            abcButton.widthAnchor.constraint(equalToConstant: 45),

            toggleButton.leadingAnchor.constraint(equalTo: abcButton.trailingAnchor, constant: 8),
            toggleButton.widthAnchor.constraint(equalToConstant: 55)
        ])

        if let langButton = languageButton {
            // Если есть кнопка языка
            constraints.append(contentsOf: [
                langButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
                langButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
                langButton.leadingAnchor.constraint(equalTo: toggleButton.trailingAnchor, constant: 8),
                langButton.widthAnchor.constraint(equalToConstant: 40),

                spaceButton.leadingAnchor.constraint(equalTo: langButton.trailingAnchor, constant: 8),
                spaceButton.widthAnchor.constraint(equalToConstant: 80)
            ])
        } else {
            // Если нет кнопки языка, пробел больше
            constraints.append(contentsOf: [
                spaceButton.leadingAnchor.constraint(equalTo: toggleButton.trailingAnchor, constant: 8),
                spaceButton.widthAnchor.constraint(equalToConstant: 120)
            ])
        }

        constraints.append(contentsOf: [
            sallaButton.leadingAnchor.constraint(equalTo: spaceButton.trailingAnchor, constant: 8),
            sallaButton.widthAnchor.constraint(equalToConstant: 40),

            deleteButton.leadingAnchor.constraint(equalTo: sallaButton.trailingAnchor, constant: 8),
            deleteButton.widthAnchor.constraint(equalToConstant: 45),

            returnButton.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 8),
            returnButton.trailingAnchor.constraint(equalTo: controlRow.trailingAnchor),
            returnButton.widthAnchor.constraint(equalToConstant: 50)
        ])

        NSLayoutConstraint.activate(constraints)

        return controlRow
    }

    private func populateIslamicContent(in contentView: UIView) {
        // Удаляем старый контент
        contentView.subviews.forEach { $0.removeFromSuperview() }

        let items: [String]
        if islamicMode == .phrases {
            items = phrasesManager.selectedPhrases.map { $0.displayText(for: languageManager.currentLanguage) }
        } else {
            items = duaManager.selectedDuas.map { $0.displayText(for: languageManager.currentLanguage) }
        }

        guard !items.isEmpty else { return }

        var previousRow: UIView?
        let itemsPerRow = 2
        let buttonHeight: CGFloat = 55
        let buttonSpacing: CGFloat = 10
        let rowSpacing: CGFloat = 12

        // Создаем кнопки по 2 в ряд
        for i in stride(from: 0, to: items.count, by: itemsPerRow) {
            let rowView = UIView()
            rowView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(rowView)

            // Создаем кнопки для текущего ряда
            var rowButtons: [UIButton] = []
            for j in 0..<itemsPerRow {
                let index = i + j
                if index < items.count {
                    let keyType: KeyType = islamicMode == .phrases ? .islamicPhrase(items[index]) : .islamicDua(items[index])
                    let button = createKeyButton(for: keyType, rowIndex: i/itemsPerRow, keyIndex: j)
                    rowView.addSubview(button)
                    rowButtons.append(button)
                }
            }

            // Настраиваем ограничения для ряда
            NSLayoutConstraint.activate([
                rowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                rowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                rowView.heightAnchor.constraint(equalToConstant: buttonHeight)
            ])

            if let previous = previousRow {
                rowView.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: rowSpacing).isActive = true
            } else {
                rowView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            }

            // Настраиваем ограничения для кнопок в ряду
            for (index, button) in rowButtons.enumerated() {
                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: rowView.topAnchor),
                    button.heightAnchor.constraint(equalTo: rowView.heightAnchor)
                ])

                if index == 0 {
                    button.leadingAnchor.constraint(equalTo: rowView.leadingAnchor).isActive = true
                } else {
                    button.leadingAnchor.constraint(equalTo: rowButtons[index-1].trailingAnchor, constant: buttonSpacing).isActive = true
                    button.widthAnchor.constraint(equalTo: rowButtons[0].widthAnchor).isActive = true
                }

                if index == rowButtons.count - 1 {
                    if rowButtons.count == 1 {
                        button.trailingAnchor.constraint(equalTo: rowView.trailingAnchor).isActive = true
                    } else {
                        // Для двух кнопок делаем их равными по ширине
                        button.trailingAnchor.constraint(equalTo: rowView.trailingAnchor).isActive = true
                    }
                }
            }

            previousRow = rowView
        }

        // Устанавливаем высоту контента
        if let lastRow = previousRow {
            lastRow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
    }
    
    private func createKeyRows() {
        // Принудительно обновляем цветовую тему
        colorManager.reloadThemeFromUserDefaults()

        // Удаляем старые кнопки
        keyboardView.subviews.forEach { $0.removeFromSuperview() }
        
        let layout = getCurrentLayout()
        
        for (rowIndex, row) in layout.enumerated() {
            let rowView = createRowView(for: row, rowIndex: rowIndex)
            keyboardView.addSubview(rowView)
            
            NSLayoutConstraint.activate([
                rowView.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor),
                rowView.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor),
                rowView.heightAnchor.constraint(equalToConstant: keyHeight)
            ])
            
            if rowIndex == 0 {
                rowView.topAnchor.constraint(equalTo: keyboardView.topAnchor).isActive = true
            } else {
                let previousRow = keyboardView.subviews[rowIndex - 1]
                rowView.topAnchor.constraint(equalTo: previousRow.bottomAnchor, constant: rowSpacing).isActive = true
            }
        }
    }
    
    private func getCurrentLayout() -> [[KeyType]] {
        switch currentMode {
        case .letters:
            return getLetterLayout()
        case .numbers:
            return getNumberLayout()
        case .symbols:
            return getSymbolLayout()
        case .islamic:
            return getIslamicLayout()
        }
    }

    private func createRowView(for row: [KeyType], rowIndex: Int) -> UIView {
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false

        var buttons: [UIButton] = []

        // Создаем все кнопки
        for (keyIndex, keyType) in row.enumerated() {
            let button = createKeyButton(for: keyType, rowIndex: rowIndex, keyIndex: keyIndex)
            rowView.addSubview(button)
            buttons.append(button)

            // Высота кнопки
            button.heightAnchor.constraint(equalTo: rowView.heightAnchor).isActive = true
            button.topAnchor.constraint(equalTo: rowView.topAnchor).isActive = true
        }

        // Настраиваем расположение кнопок в зависимости от ряда
        setupRowConstraints(buttons: buttons, rowView: rowView, row: row, rowIndex: rowIndex)

        return rowView
    }

    private func setupRowConstraints(buttons: [UIButton], rowView: UIView, row: [KeyType], rowIndex: Int) {
        guard !buttons.isEmpty else { return }

        // Первая кнопка привязана к левому краю
        buttons[0].leadingAnchor.constraint(equalTo: rowView.leadingAnchor).isActive = true

        // Последняя кнопка привязана к правому краю
        buttons.last!.trailingAnchor.constraint(equalTo: rowView.trailingAnchor).isActive = true

        // Настраиваем ширину и расстояния между кнопками
        for (index, button) in buttons.enumerated() {
            let keyType = row[index]

            if index > 0 {
                // Расстояние между кнопками
                button.leadingAnchor.constraint(equalTo: buttons[index-1].trailingAnchor, constant: keySpacing).isActive = true
            }

            // Устанавливаем ширину кнопки
            setButtonWidthConstraints(button: button, keyType: keyType, buttons: buttons, row: row)
        }
    }

    private func setButtonWidthConstraints(button: UIButton, keyType: KeyType, buttons: [UIButton], row: [KeyType]) {
        switch keyType {
        case .space:
            // Пробел занимает оставшееся место между другими кнопками
            // Не устанавливаем фиксированную ширину - она будет вычислена автоматически
            break
        case .shift, .delete:
            // Shift и Delete - фиксированная ширина как в iOS
            button.widthAnchor.constraint(equalToConstant: 42).isActive = true
        case .returnKey:
            // Return кнопка - фиксированная ширина
            button.widthAnchor.constraint(equalToConstant: 77).isActive = true
        case .numbers, .symbols, .letter("ABC"):
            // Кнопки переключения режима - фиксированная ширина
            button.widthAnchor.constraint(equalToConstant: 42).isActive = true
        case .moon, .globe:
            // Специальные кнопки - маленькие как в iOS
            button.widthAnchor.constraint(equalToConstant: 42).isActive = true
        case .islamicPhrase, .islamicDua:
            // Исламские кнопки - равномерно распределяем по ширине
            if row.allSatisfy({
                if case .islamicPhrase = $0 { return true }
                if case .islamicDua = $0 { return true }
                return false
            }) {
                // Если весь ряд состоит из исламских кнопок, делаем их равными
                for otherButton in buttons {
                    if otherButton != button {
                        button.widthAnchor.constraint(equalTo: otherButton.widthAnchor).isActive = true
                        break
                    }
                }
            } else {
                button.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
            }
        default:
            // Обычные кнопки букв/цифр - равная ширина в ряду
            let regularButtons = buttons.enumerated().compactMap { (index, btn) -> UIButton? in
                let keyType = row[index]
                switch keyType {
                case .letter, .number, .symbol:
                    return btn
                default:
                    return nil
                }
            }

            if regularButtons.count > 1 {
                for otherButton in regularButtons {
                    if otherButton != button {
                        button.widthAnchor.constraint(equalTo: otherButton.widthAnchor).isActive = true
                        break
                    }
                }
            } else {
                button.widthAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
            }
        }
    }

    private func createKeyButton(for keyType: KeyType, rowIndex: Int, keyIndex: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false

        // Настройка внешнего вида
        setupButtonAppearance(button: button, keyType: keyType)

        // Настройка текста/иконки
        setupButtonContent(button: button, keyType: keyType)

        // Добавление действия
        button.addTarget(self, action: #selector(keyButtonTapped(_:)), for: .touchUpInside)

        // Сохраняем тип кнопки как строку в accessibilityIdentifier
        button.accessibilityIdentifier = keyTypeToString(keyType)

        // Дополнительная отладка для кнопки ABC
        if case .letter("ABC") = keyType {
            print("🔧 Created ABC button with identifier: \(keyTypeToString(keyType))")
            print("🔧 ABC button target: \(button.allTargets)")
        }

        return button
    }

    private func setupButtonAppearance(button: UIButton, keyType: KeyType) {
        // Цвет фона зависит от типа кнопки
        switch keyType {
        case .letter, .number, .symbol:
            // Обычные кнопки - белый фон
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.black, for: .normal)
        case .shift, .delete, .numbers, .symbols:
            // Системные кнопки - серый фон
            button.backgroundColor = UIColor(red: 0.68, green: 0.71, blue: 0.74, alpha: 1.0)
            button.setTitleColor(UIColor.black, for: .normal)
        case .letter("ABC"):
            // Кнопка ABC - в исламском режиме используем цвет темы, в обычном - серый
            if currentMode == .islamic {
                button.backgroundColor = colorManager.keyboardButtonColor
                button.setTitleColor(colorManager.keyboardButtonTextColor, for: .normal)
            } else {
                button.backgroundColor = UIColor(red: 0.68, green: 0.71, blue: 0.74, alpha: 1.0)
                button.setTitleColor(UIColor.black, for: .normal)
            }
        case .space, .returnKey:
            // Пробел и Return - серый фон
            button.backgroundColor = UIColor(red: 0.68, green: 0.71, blue: 0.74, alpha: 1.0)
            button.setTitleColor(UIColor.black, for: .normal)
        case .moon:
            // Кнопка переключения на исламскую клавиатуру - используем цвет темы
            button.backgroundColor = colorManager.keyboardButtonColor
            button.setTitleColor(colorManager.keyboardButtonTextColor, for: .normal)
        case .globe:
            // Кнопка языка - используем цвет темы
            button.backgroundColor = colorManager.keyboardButtonColor
            button.setTitleColor(colorManager.keyboardButtonTextColor, for: .normal)
        case .islamicPhrase, .islamicDua:
            // Исламские кнопки - используем цвет выбранной темы
            button.backgroundColor = colorManager.keyboardButtonColor
            button.setTitleColor(colorManager.keyboardButtonTextColor, for: .normal)
        case .islamicToggle:
            // Кнопка переключения Дуа/Фразы - используем цвет темы
            button.backgroundColor = colorManager.keyboardButtonColor
            button.setTitleColor(colorManager.keyboardButtonTextColor, for: .normal)
        case .symbol(let sym) where sym == "ﷺ":
            // Специальная кнопка ﷺ - используем цвет темы
            button.backgroundColor = colorManager.keyboardButtonColor
            button.setTitleColor(colorManager.keyboardButtonTextColor, for: .normal)
        }

        // Общие настройки
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 0

        // Шрифт в зависимости от типа кнопки для дуа отдельно и для фраз также
        switch keyType {
        case .letter, .number, .symbol:
            button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .light)
        case .islamicPhrase, .islamicDua:
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        case .islamicToggle:
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        case .moon:
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        default:
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }

        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.textAlignment = .center
    }

    private func setupButtonContent(button: UIButton, keyType: KeyType) {
        switch keyType {
        case .letter(let char):
            let displayChar = (isShiftPressed || isCapsLockOn) ? char.uppercased() : char.lowercased()
            button.setTitle(displayChar, for: .normal)
        case .number(let num):
            button.setTitle(num, for: .normal)
        case .symbol(let sym):
            button.setTitle(sym, for: .normal)
        case .space:
            let spaceTitle: String
            switch currentLanguage {
            case .english:
                spaceTitle = "space"
            case .russian:
                spaceTitle = "пробел"
            case .kazakh:
                spaceTitle = "бос орын"
            case .arabic:
                spaceTitle = "مسافة"
            }
            button.setTitle(spaceTitle, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        case .delete:
            button.setTitle("⌫", for: .normal)
        case .shift:
            button.setTitle("⇧", for: .normal)
        case .returnKey:
            button.setTitle("⏎", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        case .numbers:
            button.setTitle("123", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        case .symbols:
            button.setTitle("#+=", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        case .letter("ABC"):
            // Кнопка переключения на следующую клавиатуру iOS - всегда показываем логотип
            var logoImage: UIImage?

            // Сначала пробуем из KeyboardApp Assets
            logoImage = UIImage(named: "IOSKeyboardIcon")

            // Если не найдено, пробуем из основного bundle
            if logoImage == nil {
                if let mainBundle = Bundle(identifier: "school.nfactorial.muslim.keyboard") {
                    logoImage = UIImage(named: "IOSKeyboardIcon", in: mainBundle, compatibleWith: nil)
                }
            }

            if let image = logoImage {
                let resizedImage = image.resized(to: CGSize(width: 24, height: 24))
                button.setImage(resizedImage, for: .normal)
                button.setTitle(nil, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
                button.imageView?.tintColor = nil
                print("✅ ABC button configured with logo image")
            } else {
                // Fallback - показываем глобус если логотип не найден
                button.setTitle("🌐", for: .normal)
                button.setImage(nil, for: .normal)
                print("⚠️ ABC button fallback to globe icon - logo not found")
            }

            // Настраиваем цвет фона в зависимости от режима
            if currentMode == .islamic {
                button.backgroundColor = colorManager.keyboardButtonColor
            } else {
                button.backgroundColor = UIColor(red: 0.68, green: 0.71, blue: 0.74, alpha: 1.0)
            }
        case .globe:
            // В исламской клавиатуре показываем текущий язык
            if currentMode == .islamic {
                let languageText: String
                switch currentLanguage {
                case .english:
                    languageText = "EN"
                case .russian:
                    languageText = "RU"
                case .kazakh:
                    languageText = "KZ"
                case .arabic:
                    languageText = "AR"
                }
                button.setTitle(languageText, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            } else {
                button.setTitle("🌐", for: .normal)
            }
        case .moon:
            // Показываем логотип для переключения на исламскую клавиатуру
            var logoImage: UIImage?

            // Сначала пробуем из KeyboardApp Assets
            logoImage = UIImage(named: "KeyboardIcon")

            // Если не найдено, пробуем из основного bundle
            if logoImage == nil {
                if let mainBundle = Bundle(identifier: "school.nfactorial.muslim.keyboard") {
                    logoImage = UIImage(named: "KeyboardIcon", in: mainBundle, compatibleWith: nil)
                }
            }

            if let image = logoImage {
                let resizedImage = image.resized(to: CGSize(width: 24, height: 24))
                button.setImage(resizedImage, for: .normal)
                button.setTitle(nil, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
                button.imageView?.tintColor = nil
                print("✅ KeyboardIcon loaded successfully")
            } else {
                // Fallback - показываем луну
                button.setTitle("🌙", for: .normal)
                print("❌ KeyboardIcon not found, using fallback")
            }
        case .islamicToggle:
            let title: String
            if islamicMode == .phrases {
                switch currentLanguage {
                case .english:
                    title = "Dua"
                case .russian:
                    title = "Дуа"
                case .kazakh:
                    title = "Дұға"
                case .arabic:
                    title = "دعاء"
                }
            } else {
                switch currentLanguage {
                case .english:
                    title = "Phrases"
                case .russian:
                    title = "Фразы"
                case .kazakh:
                    title = "Сөздер"
                case .arabic:
                    title = "عبارات"
                }
            }
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        case .islamicPhrase(let text):
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        case .islamicDua(let text):
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
    }

    private func keyTypeToString(_ keyType: KeyType) -> String {
        switch keyType {
        case .letter(let char): return "letter:\(char)"
        case .number(let num): return "number:\(num)"
        case .symbol(let sym): return "symbol:\(sym)"
        case .space: return "space"
        case .delete: return "delete"
        case .shift: return "shift"
        case .returnKey: return "return"
        case .numbers: return "numbers"
        case .symbols: return "symbols"
        case .letter("ABC"): return "abc"
        case .globe: return "globe"
        case .moon: return "moon"
        case .islamicPhrase(let text): return "phrase:\(text)"
        case .islamicDua(let text): return "dua:\(text)"
        case .islamicToggle: return "islamicToggle"
        }
    }

    private func stringToKeyType(_ string: String) -> KeyType {
        let components = string.split(separator: ":", maxSplits: 1)
        let type = String(components[0])
        let value = components.count > 1 ? String(components[1]) : ""

        switch type {
        case "letter": return .letter(value)
        case "number": return .number(value)
        case "symbol": return .symbol(value)
        case "space": return .space
        case "delete": return .delete
        case "shift": return .shift
        case "return": return .returnKey
        case "numbers": return .numbers
        case "symbols": return .symbols
        case "abc": return .letter("ABC")
        case "globe": return .globe
        case "moon": return .moon
        case "phrase": return .islamicPhrase(value)
        case "dua": return .islamicDua(value)
        case "islamicToggle": return .islamicToggle
        default: return .letter("A")
        }
    }

    // MARK: - Actions
    @objc private func keyButtonTapped(_ sender: UIButton) {
        guard let identifier = sender.accessibilityIdentifier else {
            print("❌ Button tapped but no identifier found")
            return
        }
        let keyType = stringToKeyType(identifier)
        print("🔘 Button tapped: \(identifier)")

        switch keyType {
        case .letter("ABC"):
            // Переключаемся на следующую клавиатуру iOS (системную)
            print("🔄 ABC button tapped - switching to next iOS keyboard")
            print("🔧 Available input modes: \(textDocumentProxy.documentInputMode?.primaryLanguage ?? "unknown")")
            print("🔧 needsInputModeSwitchKey: \(needsInputModeSwitchKey)")

            // Проверяем, есть ли другие клавиатуры в системе
            if hasMultipleKeyboards() {
                // Есть другие клавиатуры - используем стандартный метод
                print("🔧 Multiple keyboards available - using advanceToNextInputMode")
                advanceToNextInputMode()
            } else {
                // Наша клавиатура единственная - переключаемся на буквенный режим
                print("🔧 Only our keyboard available - switching to letters mode")
                if currentMode == .islamic {
                    // Если мы в исламском режиме, переключаемся на обычные буквы
                    currentMode = .letters
                    updateKeyboard()

                    // Показываем тактильную обратную связь для подтверждения переключения
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                } else {
                    // Если уже в буквенном режиме, переключаемся в исламский режим
                    print("🔧 In letters mode - switching to Islamic mode")
                    currentMode = .islamic
                    updateKeyboard()

                    // Показываем тактильную обратную связь
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            }

            print("✅ ABC button action completed")

        case .letter(let char):
            let displayChar = (isShiftPressed || isCapsLockOn) ? char.uppercased() : char.lowercased()
            textDocumentProxy.insertText(displayChar)
            lastInsertedText = nil // Сбрасываем при вводе обычных символов

            // Сбрасываем Shift после ввода буквы (если не CapsLock)
            if isShiftPressed && !isCapsLockOn {
                isShiftPressed = false
                updateKeyboard()
            }

        case .number(let num):
            textDocumentProxy.insertText(num)
            lastInsertedText = nil

        case .symbol(let sym):
            textDocumentProxy.insertText(sym)
            lastInsertedText = nil

        case .space:
            textDocumentProxy.insertText(" ")
            lastInsertedText = nil

        case .delete:
            handleDeleteTap()

        case .shift:
            handleShiftTap()

        case .returnKey:
            textDocumentProxy.insertText("\n")

        case .numbers:
            currentMode = .numbers
            updateKeyboard()

        case .symbols:
            currentMode = .symbols
            updateKeyboard()

        case .globe:
            toggleLanguage()
            // Если мы в исламском режиме, обновляем контент
            if currentMode == .islamic {
                createIslamicKeyboard()
            }

        case .moon:
            toggleIslamicMode()

        case .islamicPhrase(let text):
            handleIslamicPhraseTap(text)

        case .islamicDua(let text):
            handleIslamicDuaTap(text)

        case .islamicToggle:
            toggleIslamicContent()
        }

        // Тактильная обратная связь
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    private func toggleIslamicContent() {
        islamicMode = islamicMode == .phrases ? .duas : .phrases
        if currentMode == .islamic {
            createIslamicKeyboard()
        }
    }

    private func handleDeleteTap() {
        if let lastText = lastInsertedText {
            // Удаляем последнюю вставленную фразу/дуа
            for _ in 0..<lastText.count {
                textDocumentProxy.deleteBackward()
            }
            lastInsertedText = nil
        } else {
            // Обычное удаление одного символа
            textDocumentProxy.deleteBackward()
        }
    }

    private func handleShiftTap() {
        if isShiftPressed {
            // Двойное нажатие - включаем CapsLock
            isCapsLockOn = !isCapsLockOn
            isShiftPressed = isCapsLockOn
        } else {
            // Одинарное нажатие - включаем Shift
            isShiftPressed = true
        }
        updateKeyboard()
    }
    //06. 06. 2025 Update keyboard 

    private func toggleLanguage() {
        languageManager.toggleLanguage()
        currentLanguage = languageManager.currentLanguage
        updateKeyboard()
    }

    private func toggleIslamicMode() {
        currentMode = (currentMode == .islamic) ? .letters : .islamic
        // Удаляем старую клавиатуру и создаем новую
        keyboardView.subviews.forEach { $0.removeFromSuperview() }
        if currentMode == .islamic {
            createIslamicKeyboard()
        } else {
            createKeyRows()
        }
    }

    private func handleIslamicPhraseTap(_ displayText: String) {
        // Находим фразу по отображаемому тексту
        let selectedPhrases = phrasesManager.selectedPhrases
        if let phrase = selectedPhrases.first(where: { $0.displayText(for: languageManager.currentLanguage) == displayText }) {
            let useArabic = languageManager.shouldUseArabicForCurrentLanguage()
            let textToInsert = phrase.insertText(for: languageManager.currentLanguage, useArabic: useArabic)
            textDocumentProxy.insertText(textToInsert)
            lastInsertedText = textToInsert
        }
    }

    private func handleIslamicDuaTap(_ displayText: String) {
        // Находим дуа по отображаемому тексту
        let selectedDuas = duaManager.selectedDuas
        if let dua = selectedDuas.first(where: { $0.displayText(for: languageManager.currentLanguage) == displayText }) {
            let useArabicForDua = languageManager.shouldUseArabicForDuaCurrentLanguage()
            let textToInsert = dua.insertText(for: languageManager.currentLanguage, useArabicForDua: useArabicForDua)
            textDocumentProxy.insertText(textToInsert)
            lastInsertedText = textToInsert
        }
    }

    private func updateKeyboard() {
        if currentMode == .islamic {
            createIslamicKeyboard()
        } else {
            createKeyRows()
        }
    }

    // MARK: - Refresh and Update Methods
    private func refreshKeyboardData() {
        // Обновляем данные из UserDefaults
        phrasesManager.refreshData()
        duaManager.refreshData()
        languageManager.refreshLanguageFromMainApp()

        // Обновляем клавиатуру
        updateKeyboard()
    }

    @objc private func colorThemeChanged() {
        // Перезагружаем тему из UserDefaults
        colorManager.reloadThemeFromUserDefaults()
        print("🎨 Color theme changed, recreating keyboard...")

        // Пересоздаем клавиатуру полностью для надежности
        updateKeyboard()
    }


    private func updateAppearance() {
        // Обновляем внешний вид при изменении контекста
        if needsInputModeSwitchKey {
            // Показываем кнопку переключения клавиатуры если нужно
        }
    }

    // MARK: - Helper Methods
    private func hasMultipleKeyboards() -> Bool {
        // Проверяем несколько способов определения наличия других клавиатур

        // 1. Стандартный способ iOS
        let hasInputModeSwitch = needsInputModeSwitchKey
        print("🔧 needsInputModeSwitchKey: \(hasInputModeSwitch)")

        // 2. Проверяем через textDocumentProxy
        let hasDocumentInputMode = textDocumentProxy.documentInputMode != nil
        print("🔧 hasDocumentInputMode: \(hasDocumentInputMode)")

        // 3. Проверяем доступ
        let hasFullKeyboardAccess = hasFullAccess
        print("🔧 hasFullAccess: \(hasFullKeyboardAccess)")

        // Возвращаем true если хотя бы один из способов указывает на наличие других клавиатур
        return hasInputModeSwitch
    }

    // MARK: - Debug Methods
    private func debugResourceLoading() {
        print("🔍 Debug: Checking available resources...")

        let currentBundle = Bundle(for: type(of: self))
        print("🔍 Current bundle: \(currentBundle.bundleIdentifier ?? "unknown")")
        print("🔍 Bundle path: \(currentBundle.bundlePath)")

        // Проверяем все доступные изображения
        if let resourcePath = currentBundle.resourcePath {
            print("🔍 Resource path: \(resourcePath)")

            // Ищем все PNG файлы
            let fileManager = FileManager.default
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: resourcePath)
                let imageFiles = contents.filter { $0.hasSuffix(".png") || $0.hasSuffix(".jpg") }
                print("🔍 Available image files: \(imageFiles)")
            } catch {
                print("❌ Error reading resource directory: \(error)")
            }
        }

        // Пробуем загрузить IOSKeyboardIcon разными способами
        let methods = [
            ("Bundle.main", { UIImage(named: "IOSKeyboardIcon") }),
            ("Current bundle", { UIImage(named: "IOSKeyboardIcon", in: currentBundle, compatibleWith: nil) }),
            ("Main app bundle", {
                if let mainBundle = Bundle(identifier: "school.nfactorial.muslim.keyboard") {
                    return UIImage(named: "IOSKeyboardIcon", in: mainBundle, compatibleWith: nil)
                }
                return nil
            })
        ]

        for (methodName, loadMethod) in methods {
            if let image = loadMethod() {
                print("✅ IOSKeyboardIcon loaded successfully using \(methodName)")
                print("   Image size: \(image.size)")
                return
            } else {
                print("❌ Failed to load IOSKeyboardIcon using \(methodName)")
            }
        }

        // Дополнительная диагностика для проблем с отображением клавиатуры
        debugKeyboardVisibility()
    }

    private func debugKeyboardVisibility() {
        print("🔍 === Keyboard Visibility Debug ===")

        // Проверяем bundle identifier
        let currentBundle = Bundle(for: type(of: self))
        print("🔧 Extension Bundle ID: \(currentBundle.bundleIdentifier ?? "unknown")")

        // Проверяем основное приложение
        if let mainBundle = Bundle(identifier: "school.nfactorial.muslim.keyboard") {
            print("🔧 Main App Bundle ID: \(mainBundle.bundleIdentifier ?? "unknown")")
            print("✅ Main app bundle found")
        } else {
            print("❌ Main app bundle NOT found")
        }

        // Проверяем Info.plist настройки
        if let infoPlist = currentBundle.infoDictionary {
            print("🔧 Extension Info.plist keys:")
            if let displayName = infoPlist["CFBundleDisplayName"] as? String {
                print("   Display Name: \(displayName)")
            }
            if let extensionDict = infoPlist["NSExtension"] as? [String: Any] {
                print("   NSExtension found")
                if let pointIdentifier = extensionDict["NSExtensionPointIdentifier"] as? String {
                    print("   Point Identifier: \(pointIdentifier)")
                }
                if let attributes = extensionDict["NSExtensionAttributes"] as? [String: Any] {
                    print("   Extension Attributes:")
                    for (key, value) in attributes {
                        print("     \(key): \(value)")
                    }
                }
            }
        }

        // Проверяем доступ
        print("🔧 Has Full Access: \(hasFullAccess)")
        print("🔧 Needs Input Mode Switch: \(needsInputModeSwitchKey)")

        // Проверяем версию iOS
        let systemVersion = UIDevice.current.systemVersion
        print("🔧 iOS Version: \(systemVersion)")

        print("🔍 === End Debug ===")
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    // Создаем простую иконку клавиатуры программно
    static func createKeyboardIcon(size: CGSize, color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let ctx = context.cgContext

            // Устанавливаем цвет
            ctx.setFillColor(color.cgColor)
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(1.5)

            // Рисуем прямоугольник клавиатуры
            let keyboardRect = CGRect(x: 2, y: 6, width: size.width - 4, height: size.height - 8)
            let keyboardPath = UIBezierPath(roundedRect: keyboardRect, cornerRadius: 3)
            ctx.addPath(keyboardPath.cgPath)
            ctx.strokePath()

            // Рисуем клавиши
            let keyWidth: CGFloat = (keyboardRect.width - 8) / 3
            let keyHeight: CGFloat = (keyboardRect.height - 6) / 2

            for row in 0..<2 {
                for col in 0..<3 {
                    let x = keyboardRect.minX + 2 + CGFloat(col) * (keyWidth + 1)
                    let y = keyboardRect.minY + 2 + CGFloat(row) * (keyHeight + 1)
                    let keyRect = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
                    let keyPath = UIBezierPath(roundedRect: keyRect, cornerRadius: 1)
                    ctx.addPath(keyPath.cgPath)
                    ctx.fillPath()
                }
            }
        }
    }
}

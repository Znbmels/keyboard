import UIKit
import Foundation

// MARK: - Sticker Models (Simplified for Keyboard Extension)
struct SavedSticker: Codable, Identifiable {
    let id: String
    let prompt: String
    let contentType: String
    let imageData: Data
    let createdAt: Date

    init(id: String = UUID().uuidString, prompt: String, contentType: String, imageData: Data) {
        self.id = id
        self.prompt = prompt
        self.contentType = contentType
        self.imageData = imageData
        self.createdAt = Date()
    }
}

// Simplified StickerManager for Keyboard Extension
class StickerManager {
    static let shared = StickerManager()

    let userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
    private let stickersKey = "saved_stickers"

    var savedStickers: [SavedSticker] = []

    private init() {
        loadStickers()
    }

    func getStickersForKeyboard() -> [SavedSticker] {
        print("🎨 getStickersForKeyboard called")

        // Принудительно перезагружаем данные из UserDefaults
        loadStickers()

        print("🎨 Total saved stickers: \(savedStickers.count)")

        // Проверяем, включены ли стикеры в клавиатуре
        // По умолчанию true, если настройка не установлена
        let stickersEnabled = userDefaults.object(forKey: "stickers_enabled_in_keyboard") as? Bool ?? true
        print("🎨 Stickers enabled in keyboard: \(stickersEnabled)")
        guard stickersEnabled else {
            print("🎨 Stickers disabled, returning empty array")
            return []
        }

        // Получаем выбранные стикеры из настроек
        if let data = userDefaults.data(forKey: "selected_stickers_for_keyboard"),
           let selectedIds = try? JSONDecoder().decode(Set<String>.self, from: data) {
            print("🎨 ===== KEYBOARD STICKER FILTERING DEBUG =====")
            print("🎨 Found selected stickers data: \(selectedIds.count) IDs")
            print("🎨 Selected IDs from settings: \(Array(selectedIds))")
            print("🎨 Available stickers: \(savedStickers.count)")

            // Показываем все доступные стикеры
            for (index, sticker) in savedStickers.enumerated() {
                print("🎨 Available sticker \(index): '\(sticker.prompt)' (ID: \(sticker.id))")
            }

            let selectedStickers = savedStickers.filter { selectedIds.contains($0.id) }
            print("🎨 Filtered selected stickers: \(selectedStickers.count)")

            // Отладочная информация о каждом стикере
            for sticker in savedStickers {
                let isSelected = selectedIds.contains(sticker.id)
                print("🎨 Sticker '\(sticker.prompt)' (ID: \(sticker.id)) - Selected: \(isSelected)")
            }

            if !selectedStickers.isEmpty {
                print("🎨 ✅ Returning \(selectedStickers.count) selected stickers")
                for (index, sticker) in selectedStickers.enumerated() {
                    print("🎨 Final sticker \(index): '\(sticker.prompt)'")
                }
                return selectedStickers
            } else {
                print("🎨 ❌ No matching selected stickers found, returning empty array")
                print("🎨 This means the IDs in settings don't match any actual sticker IDs")
                return []
            }
        } else {
            print("🎨 ⚠️ No selection data found in UserDefaults, returning all \(savedStickers.count) stickers")
            return savedStickers
        }
    }

    func shouldShowStickersButton() -> Bool {
        // Проверяем, включены ли стикеры в клавиатуре
        // По умолчанию true, если настройка не установлена
        let stickersEnabled = userDefaults.object(forKey: "stickers_enabled_in_keyboard") as? Bool ?? true
        print("🎨 shouldShowStickersButton - enabled: \(stickersEnabled), stickers count: \(savedStickers.count)")

        // Если стикеров нет, создаём демо-стикеры для тестирования
        if savedStickers.isEmpty {
            print("🎨 No stickers found, creating demo stickers for keyboard...")
            createDemoStickersForKeyboard()
        }

        return stickersEnabled && !savedStickers.isEmpty
    }

    func createStickerPreview(sticker: SavedSticker, size: CGSize = CGSize(width: 35, height: 35)) -> UIImage? {
        guard let originalImage = UIImage(data: sticker.imageData) else { return nil }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Рисуем белый фон
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Рисуем изображение с небольшими отступами
            let imageRect = CGRect(
                x: 2,
                y: 2,
                width: size.width - 4,
                height: size.height - 4
            )
            originalImage.draw(in: imageRect)

            // Добавляем тонкую серую рамку
            UIColor.systemGray3.setStroke()
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 6)
            path.lineWidth = 0.5
            path.stroke()
        }
    }

    func loadStickers() {
        print("📱 Keyboard: Loading stickers from UserDefaults...")
        print("📱 Keyboard: Using standard UserDefaults")

        guard let data = userDefaults.data(forKey: stickersKey) else {
            print("📱 Keyboard: Нет сохраненных стикеров в ключе '\(stickersKey)'")

            // Проверим все ключи в UserDefaults
            let allKeys = userDefaults.dictionaryRepresentation().keys
            print("📱 Keyboard: Доступные ключи в UserDefaults: \(Array(allKeys))")
            return
        }

        do {
            savedStickers = try JSONDecoder().decode([SavedSticker].self, from: data)
            print("📱 Keyboard: Загружено стикеров: \(savedStickers.count)")
            for (index, sticker) in savedStickers.enumerated() {
                print("📱 Keyboard: Стикер \(index): \(sticker.prompt)")
            }
        } catch {
            print("❌ Keyboard: Ошибка загрузки стикеров: \(error)")
            savedStickers = []
        }
    }

    func createDemoStickersForKeyboard() {
        print("🎨 Creating demo stickers for keyboard...")
        let demoPrompts = [
            "بِسْمِ اللَّهِ",
            "الْحَمْدُ لِلَّهِ",
            "سُبْحَانَ اللَّهِ",
            "اللَّهُ أَكْبَرُ",
            "أَسْتَغْفِرُ اللَّهَ",
            "لَا إِلَهَ إِلَّا اللَّهُ",
            "مَا شَاءَ اللَّهُ",
            "بَارَكَ اللَّهُ",
            "إِنْ شَاءَ اللَّهُ",
            "جَزَاكَ اللَّهُ خَيْرًا",
            "رَبِّ اغْفِرْ لِي",
            "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ"
        ]

        var demoStickers: [SavedSticker] = []

        for prompt in demoPrompts {
            let image = createDemoStickerImage(text: prompt)
            if let imageData = image.pngData() {
                let sticker = SavedSticker(
                    prompt: prompt,
                    contentType: "TEXTUAL",
                    imageData: imageData
                )
                demoStickers.append(sticker)
            }
        }

        savedStickers = demoStickers

        // Сохраняем в UserDefaults
        do {
            let data = try JSONEncoder().encode(savedStickers)
            userDefaults.set(data, forKey: stickersKey)
            userDefaults.synchronize()
            print("🎨 Demo stickers saved to UserDefaults: \(savedStickers.count)")
        } catch {
            print("❌ Failed to save demo stickers: \(error)")
        }

        // Автоматически выбираем все демо-стикеры для клавиатуры
        let allStickerIds = Set(demoStickers.map { $0.id })
        do {
            let selectionData = try JSONEncoder().encode(allStickerIds)
            userDefaults.set(selectionData, forKey: "selected_stickers_for_keyboard")
            userDefaults.synchronize()
            print("🎨 All demo stickers selected for keyboard: \(allStickerIds.count)")
        } catch {
            print("❌ Failed to save demo sticker selection: \(error)")
        }
    }

    private func createDemoStickerImage(text: String) -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Зелёный фон
            UIColor.systemGreen.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Белый текст
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white
            ]

            let attributedText = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributedText.size()
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            attributedText.draw(in: textRect)
        }
    }
}

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
    case stickers
    case stickerBack
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
    private let stickerManager = StickerManager.shared
    
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
                [.numbers, .moon, .space, .symbol("."), .returnKey]
            ]
        case .russian:
            return [
                [.letter("Й"), .letter("Ц"), .letter("У"), .letter("К"), .letter("Е"), .letter("Н"), .letter("Г"), .letter("Ш"), .letter("Щ"), .letter("З"), .letter("Х")],
                [.letter("Ф"), .letter("Ы"), .letter("В"), .letter("А"), .letter("П"), .letter("Р"), .letter("О"), .letter("Л"), .letter("Д"), .letter("Ж"), .letter("Э")],
                [.shift, .letter("Я"), .letter("Ч"), .letter("С"), .letter("М"), .letter("И"), .letter("Т"), .letter("Ь"), .letter("Б"), .letter("Ю"), .delete],
                [.numbers, .moon, .space, .symbol("."), .returnKey]
            ]
        case .kazakh:
            return [
                [.letter("Й"), .letter("Ц"), .letter("У"), .letter("К"), .letter("Е"), .letter("Н"), .letter("Г"), .letter("Ш"), .letter("Щ"), .letter("З"), .letter("Х")],
                [.letter("Ф"), .letter("Ы"), .letter("В"), .letter("А"), .letter("П"), .letter("Р"), .letter("О"), .letter("Л"), .letter("Д"), .letter("Ж"), .letter("Э")],
                [.shift, .letter("Я"), .letter("Ч"), .letter("С"), .letter("М"), .letter("И"), .letter("Т"), .letter("Ь"), .letter("Б"), .letter("Ю"), .delete],
                [.numbers, .moon, .space, .symbol("."), .returnKey]
            ]
        case .arabic:
            return [
                [.letter("ض"), .letter("ص"), .letter("ث"), .letter("ق"), .letter("ف"), .letter("غ"), .letter("ع"), .letter("ه"), .letter("خ"), .letter("ح")],
                [.letter("ش"), .letter("س"), .letter("ي"), .letter("ب"), .letter("ل"), .letter("ا"), .letter("ت"), .letter("ن"), .letter("م")],
                [.shift, .letter("ظ"), .letter("ط"), .letter("ذ"), .letter("د"), .letter("ز"), .letter("ر"), .letter("و"), .delete],
                [.numbers, .moon, .space, .symbol("."), .returnKey]
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

        // Добавляем наблюдатель для изменений настроек стикеров
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stickerSettingsChanged),
            name: NSNotification.Name("StickerSettingsChanged"),
            object: nil
        )

        // Добавляем наблюдатель для изменений выбранных стикеров
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stickerSelectionChanged),
            name: NSNotification.Name("StickerSelectionChanged"),
            object: nil
        )

        // Добавляем наблюдатель для изменений видимости стикеров
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stickerVisibilityChanged),
            name: NSNotification.Name("StickerVisibilityChanged"),
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

        // Принудительно обновляем стикеры
        stickerManager.loadStickers()

        // Дополнительная отладочная информация
        print("🎨 Islamic keyboard creation - stickers count: \(stickerManager.savedStickers.count)")
        print("🎨 Islamic keyboard creation - should show button: \(stickerManager.shouldShowStickersButton())")

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

        // Проверяем настройку отображения стикеров
        let userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
        let shouldShowStickers = userDefaults.object(forKey: "stickers_enabled_in_keyboard") as? Bool ?? true
        var stickersButton: UIButton?

        if shouldShowStickers {
            print("🎨 Creating stickers button...")
            print("🎨 StickerManager saved stickers count: \(stickerManager.savedStickers.count)")

            // Убеждаемся, что стикеры загружены
            stickerManager.loadStickers()

            // Если стикеров нет, создаём демо-стикеры
            if stickerManager.savedStickers.isEmpty {
                stickerManager.createDemoStickersForKeyboard()
            }

            stickersButton = createKeyButton(for: .stickers, rowIndex: 0, keyIndex: 2)
            print("🎨 Stickers button created successfully with \(stickerManager.savedStickers.count) stickers")
        } else {
            print("🎨 Stickers button hidden by user setting")
        }

        let spaceButton = createKeyButton(for: .space, rowIndex: 0, keyIndex: 4)
        let sallaButton = createKeyButton(for: .symbol("ﷺ"), rowIndex: 0, keyIndex: 5)
        let deleteButton = createKeyButton(for: .delete, rowIndex: 0, keyIndex: 6)
        let returnButton = createKeyButton(for: .returnKey, rowIndex: 0, keyIndex: 7)

        controlRow.addSubview(abcButton)
        controlRow.addSubview(toggleButton)

        // Добавляем кнопку стикеров только если она создана
        if let stickersButton = stickersButton {
            controlRow.addSubview(stickersButton)
            print("🎨 Stickers button added to controlRow")
        }

        controlRow.addSubview(spaceButton)
        controlRow.addSubview(sallaButton)
        controlRow.addSubview(deleteButton)
        controlRow.addSubview(returnButton)

        // Добавляем кнопку языка только если доступно больше одного языка
        var languageButton: UIButton?
        if languageManager.shouldShowLanguageToggle {
            languageButton = createKeyButton(for: .globe, rowIndex: 0, keyIndex: 3)
            controlRow.addSubview(languageButton!)
        }

        // Настраиваем ограничения
        var constraints: [NSLayoutConstraint] = []

        // Высота кнопок
        var heightConstraints: [NSLayoutConstraint] = [
            abcButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
            toggleButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
            spaceButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
            sallaButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
            deleteButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
            returnButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor)
        ]

        // Добавляем ограничения для кнопки стикеров только если она существует
        if let stickersButton = stickersButton {
            heightConstraints.append(stickersButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor))
        }

        constraints.append(contentsOf: heightConstraints)

        // Вертикальное выравнивание
        var topConstraints: [NSLayoutConstraint] = [
            abcButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
            toggleButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
            spaceButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
            sallaButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
            deleteButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
            returnButton.topAnchor.constraint(equalTo: controlRow.topAnchor)
        ]

        // Добавляем ограничения для кнопки стикеров только если она существует
        if let stickersButton = stickersButton {
            topConstraints.append(stickersButton.topAnchor.constraint(equalTo: controlRow.topAnchor))
        }

        constraints.append(contentsOf: topConstraints)

        // Горизонтальное расположение
        constraints.append(contentsOf: [
            abcButton.leadingAnchor.constraint(equalTo: controlRow.leadingAnchor),
            abcButton.widthAnchor.constraint(equalToConstant: 40),

            toggleButton.leadingAnchor.constraint(equalTo: abcButton.trailingAnchor, constant: 6),
            toggleButton.widthAnchor.constraint(equalToConstant: 45)
        ])

        // Определяем последнюю кнопку перед пробелом
        let lastButtonBeforeSpace: UIButton
        if let stickersButton = stickersButton {
            constraints.append(contentsOf: [
                stickersButton.leadingAnchor.constraint(equalTo: toggleButton.trailingAnchor, constant: 6),
                stickersButton.widthAnchor.constraint(equalToConstant: 35)
            ])
            lastButtonBeforeSpace = stickersButton
        } else {
            lastButtonBeforeSpace = toggleButton
        }

        if let langButton = languageButton {
            // Если есть кнопка языка
            constraints.append(contentsOf: [
                langButton.heightAnchor.constraint(equalTo: controlRow.heightAnchor),
                langButton.topAnchor.constraint(equalTo: controlRow.topAnchor),
                langButton.leadingAnchor.constraint(equalTo: lastButtonBeforeSpace.trailingAnchor, constant: 6),
                langButton.widthAnchor.constraint(equalToConstant: 35),

                spaceButton.leadingAnchor.constraint(equalTo: langButton.trailingAnchor, constant: 6),
                spaceButton.widthAnchor.constraint(equalToConstant: 70)
            ])
        } else {
            // Если нет кнопки языка, пробел больше
            let spaceWidth: CGFloat = 105 // Фиксированная ширина, так как кнопка стикеров всегда есть
            constraints.append(contentsOf: [
                spaceButton.leadingAnchor.constraint(equalTo: lastButtonBeforeSpace.trailingAnchor, constant: 6),
                spaceButton.widthAnchor.constraint(equalToConstant: spaceWidth)
            ])
        }

        constraints.append(contentsOf: [
            sallaButton.leadingAnchor.constraint(equalTo: spaceButton.trailingAnchor, constant: 6),
            sallaButton.widthAnchor.constraint(equalToConstant: 35),

            deleteButton.leadingAnchor.constraint(equalTo: sallaButton.trailingAnchor, constant: 6),
            deleteButton.widthAnchor.constraint(equalToConstant: 40),

            returnButton.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 6),
            returnButton.trailingAnchor.constraint(equalTo: controlRow.trailingAnchor),
            returnButton.widthAnchor.constraint(equalToConstant: 45)
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
            // Пробел - увеличенная ширина для удобства
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
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
        case .symbol(let sym) where sym == ".":
            // Точка - уменьшенная ширина
            button.widthAnchor.constraint(equalToConstant: 32).isActive = true
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
                case .letter, .number:
                    return btn
                case .symbol(let sym) where sym != ".":
                    // Исключаем точку из обычных символов
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
        case .stickers:
            // Кнопка стикеров - используем цвет темы
            button.backgroundColor = colorManager.keyboardButtonColor
            button.setTitleColor(colorManager.keyboardButtonTextColor, for: .normal)
        case .stickerBack:
            // Кнопка возврата из стикеров - серый фон для белого интерфейса
            button.backgroundColor = UIColor.systemGray5
            button.setTitleColor(.black, for: .normal)
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
        case .stickers:
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
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
        case .stickers:
            // Показываем иконку стикеров со смайликом
            button.setTitle("😊", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        case .stickerBack:
            // Кнопка возврата из стикеров - только стрелочка
            button.setTitle("←", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
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
        case .stickers: return "stickers"
        case .stickerBack: return "stickerBack"
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
        case "stickers": return .stickers
        case "stickerBack": return .stickerBack
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

        case .stickers:
            showStickerLibrary()

        case .stickerBack:
            returnToIslamicKeyboard()
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

    private func showStickerLibrary() {
        // Создаем и показываем библиотеку стикеров в клавиатуре
        if currentMode == .islamic {
            createStickerKeyboard()
        }
    }

    private func createStickerKeyboard() {
        // Увеличиваем высоту клавиатуры для стикеров
        updateKeyboardHeight(300) // Увеличиваем до 300 пикселей

        // Очищаем текущий контент
        keyboardView.subviews.forEach { $0.removeFromSuperview() }

        // Принудительно перезагружаем стикеры из UserDefaults
        stickerManager.loadStickers()

        // ПРИНУДИТЕЛЬНО создаем демо-стикеры если их нет
        if stickerManager.savedStickers.isEmpty {
            print("🎨 No stickers found, creating demo stickers...")
            stickerManager.createDemoStickersForKeyboard()
        }

        // Получаем только выбранные стикеры для клавиатуры
        let stickers = stickerManager.getStickersForKeyboard()

        print("🎨 Creating sticker keyboard with \(stickers.count) selected stickers")
        print("🎨 Total saved stickers: \(stickerManager.savedStickers.count)")
        print("🎨 Selected stickers for keyboard: \(stickers.count)")

        // Выводим информацию о каждом стикере
        for (index, sticker) in stickers.enumerated() {
            print("🎨 Sticker \(index): '\(sticker.prompt)' (ID: \(sticker.id))")
        }

        if stickers.isEmpty {
            // Показываем сообщение о пустой библиотеке
            createEmptyStickerView()
        } else {
            // Показываем стикеры
            createStickerGrid(stickers: stickers)
        }
    }

    private func createEmptyStickerView() {
        let emptyView = UIView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.backgroundColor = .white
        keyboardView.addSubview(emptyView)

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        // Отладочная информация
        let totalStickers = stickerManager.savedStickers.count
        let debugText = "🎨 DEBUG INFO\n\nTotal saved stickers: \(totalStickers)\nFiltered stickers: 0\n\nОткройте приложение и создайте\nваш первый исламский стикер!"

        messageLabel.text = debugText
        messageLabel.textColor = .darkGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyView.addSubview(messageLabel)

        // Кнопка возврата - только стрелочка
        let backButton = createKeyButton(for: .stickerBack, rowIndex: 0, keyIndex: 0)
        emptyView.addSubview(backButton)

        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: keyboardView.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: keyboardView.bottomAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20),

            backButton.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor, constant: -10),
            backButton.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func createStickerGrid(stickers: [SavedSticker]) {

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        keyboardView.addSubview(containerView)

        // Добавляем заголовок с отладочной информацией
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "🎨 Stickers: \(stickers.count) / \(stickerManager.savedStickers.count)"
        headerLabel.textColor = .darkGray
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        containerView.addSubview(headerLabel)

        // Создаем скролл-вью для стикеров
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true // Включаем вертикальный скролл
        scrollView.isScrollEnabled = true
        scrollView.bounces = true
        containerView.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Создаем кнопки стикеров - увеличенный размер для лучшего отображения
        let stickersPerRow = 4
        let stickerSize: CGFloat = 60
        let spacing: CGFloat = 12
        let margin: CGFloat = 16

        var stickerButtons: [UIButton] = []

        print("🎨 Creating \(stickers.count) sticker buttons...")

        for (index, sticker) in stickers.enumerated() {
            print("🎨 Creating button \(index) for sticker: '\(sticker.prompt)'")
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = index

            // Упрощенное отображение - показываем текст стикера
            let displayText = sticker.prompt.count > 8 ? String(sticker.prompt.prefix(8)) + "..." : sticker.prompt
            button.setTitle(displayText, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center

            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemGray3.cgColor

            // Добавляем тень для лучшего визуального эффекта
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowOpacity = 0.1
            button.layer.shadowRadius = 2
            button.layer.masksToBounds = false

            // Эффект нажатия
            button.addTarget(self, action: #selector(stickerButtonPressed(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(stickerButtonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

            // Добавляем действие
            button.addTarget(self, action: #selector(stickerButtonTapped(_:)), for: .touchUpInside)

            contentView.addSubview(button)
            stickerButtons.append(button)
            print("🎨 Added button \(index) to contentView")
        }

        print("🎨 Total buttons created and added: \(stickerButtons.count)")

        // Кнопка возврата - только стрелочка
        let backButton = createKeyButton(for: .stickerBack, rowIndex: 0, keyIndex: 0)
        containerView.addSubview(backButton)

        // Настраиваем ограничения
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: keyboardView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: keyboardView.bottomAnchor),

            // Заголовок
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            headerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 20),

            scrollView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 5),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -50),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            backButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Размещаем кнопки стикеров в сетке
        let rows = (stickers.count + stickersPerRow - 1) / stickersPerRow
        let contentHeight = CGFloat(rows) * (stickerSize + spacing) + margin

        print("🎨 Grid layout: \(stickers.count) stickers, \(rows) rows, content height: \(contentHeight)")

        contentView.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true

        for (index, button) in stickerButtons.enumerated() {
            let row = index / stickersPerRow
            let col = index % stickersPerRow

            let x = margin + CGFloat(col) * (stickerSize + spacing)
            let y = margin + CGFloat(row) * (stickerSize + spacing)

            print("🎨 Button \(index): row=\(row), col=\(col), x=\(x), y=\(y)")

            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: x),
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: y),
                button.widthAnchor.constraint(equalToConstant: stickerSize),
                button.heightAnchor.constraint(equalToConstant: stickerSize)
            ])
        }
    }

    @objc private func stickerButtonPressed(_ sender: UIButton) {
        // Анимация нажатия
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }
    }

    @objc private func stickerButtonReleased(_ sender: UIButton) {
        // Анимация отпускания
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity
            sender.alpha = 1.0
        }
    }

    @objc private func stickerButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let stickers = stickerManager.getStickersForKeyboard()

        guard index < stickers.count else { return }

        let sticker = stickers[index]

        // Пытаемся вставить стикер как изображение в PNG формате
        if let image = UIImage(data: sticker.imageData) {
            print("🎨 Processing sticker: '\(sticker.prompt)' as PNG image")
            insertStickerImage(image)
        } else {
            // Fallback - вставляем текст с индикатором PNG
            print("🎨 No image data found, inserting text fallback")
            textDocumentProxy.insertText("🎨 \(sticker.prompt) [PNG]")
        }

        // Возвращаемся к исламской клавиатуре
        createIslamicKeyboard()

        // Тактильная обратная связь
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    private func insertStickerImage(_ image: UIImage) {
        print("🎨 Attempting to insert sticker image as PNG")

        // Метод 1: Современный API для iOS 13+
        if #available(iOS 13.0, *) {
            insertImageWithModernAPI(image)
            return
        }

        // Метод 2: Попытка вставить изображение через UIPasteboard
        if insertImageViaPasteboard(image) {
            print("🎨 Sticker inserted via pasteboard")
            return
        }

        // Метод 3: Попытка вставить изображение через NSTextAttachment (если поддерживается)
        if insertImageViaTextAttachment(image) {
            print("🎨 Sticker inserted via text attachment")
            return
        }

        // Метод 4: Fallback - сохраняем как PNG файл и вставляем индикатор
        insertImageViaPhotosLibrary(image)
    }

    private func insertImageViaPasteboard(_ image: UIImage) -> Bool {
        // Конвертируем изображение в PNG данные
        guard let pngData = image.pngData() else {
            print("🎨 Failed to convert image to PNG data")
            return false
        }

        // Создаем NSItemProvider для изображения
        let itemProvider = NSItemProvider(item: pngData as NSData, typeIdentifier: "public.png")

        // Сохраняем изображение в буфер обмена с правильным типом
        let pasteboard = UIPasteboard.general
        pasteboard.itemProviders = [itemProvider]

        // Альтернативный способ - устанавливаем изображение напрямую
        pasteboard.image = image

        // Пытаемся использовать специальный метод для вставки изображений (iOS 10+)
        if #available(iOS 10.0, *) {
            // Создаем NSTextAttachment для более корректной вставки
            let attachment = NSTextAttachment()
            attachment.image = image

            // Масштабируем изображение для удобства
            let maxSize: CGFloat = 120
            let aspectRatio = image.size.width / image.size.height
            let newSize: CGSize

            if aspectRatio > 1 {
                // Широкое изображение
                newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
            } else {
                // Высокое изображение
                newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
            }

            attachment.bounds = CGRect(origin: .zero, size: newSize)
        }

        // Добавляем пробел перед изображением если есть текст
        if textDocumentProxy.hasText {
            textDocumentProxy.insertText(" ")
        }

        // Вставляем индикатор изображения с информацией о PNG
        let fileSizeKB = Double(pngData.count) / 1024.0
        let sizeText = fileSizeKB > 1 ? String(format: "%.1fKB", fileSizeKB) : "\(pngData.count)B"
        textDocumentProxy.insertText("🖼️ PNG (\(sizeText))")

        print("🎨 Image saved to pasteboard as PNG (\(pngData.count) bytes, \(sizeText))")
        return true
    }

    private func insertImageViaTextAttachment(_ image: UIImage) -> Bool {
        // Создаем NSTextAttachment с изображением
        let attachment = NSTextAttachment()
        attachment.image = image

        // Устанавливаем размер изображения (например, 100x100 пикселей)
        let imageSize = CGSize(width: 100, height: 100)
        attachment.bounds = CGRect(origin: .zero, size: imageSize)

        // Создаем attributed string с изображением
        let attributedString = NSAttributedString(attachment: attachment)

        // Пытаемся вставить attributed string
        // Примечание: не все приложения поддерживают это
        if textDocumentProxy is UITextInput & UITextInputTraits {
            // Этот метод может не работать во всех приложениях
            textDocumentProxy.insertText(attributedString.string)
            return true
        }

        return false
    }

    private func insertImageViaPhotosLibrary(_ image: UIImage) {
        // Сохраняем изображение во временную папку как PNG
        if let pngData = image.pngData() {
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "islamic_sticker_\(UUID().uuidString).png"
            let fileURL = tempDir.appendingPathComponent(fileName)

            do {
                try pngData.write(to: fileURL)
                print("🎨 Sticker saved as PNG: \(fileURL.path)")

                // Сохраняем путь к файлу в буфер обмена для возможного использования
                let pasteboard = UIPasteboard.general
                pasteboard.string = fileURL.absoluteString

                // Вставляем индикатор с информацией о файле
                textDocumentProxy.insertText("🖼️ PNG")

            } catch {
                print("🎨 Failed to save PNG file: \(error)")
                textDocumentProxy.insertText("🖼️ [Исламский стикер]")
            }
        } else {
            print("🎨 Failed to convert image to PNG data")
            textDocumentProxy.insertText("🖼️ [Исламский стикер]")
        }
    }

    // MARK: - Advanced Image Insertion Methods

    private func insertImageWithModernAPI(_ image: UIImage) {
        // Для iOS 13+ можно использовать более современные API
        if #available(iOS 13.0, *) {
            insertImageWithDragAndDrop(image)
        } else {
            _ = insertImageViaPasteboard(image)
        }
    }

    @available(iOS 13.0, *)
    private func insertImageWithDragAndDrop(_ image: UIImage) {
        // Создаем NSItemProvider для изображения
        guard let pngData = image.pngData() else { return }

        let itemProvider = NSItemProvider()
        itemProvider.registerDataRepresentation(forTypeIdentifier: "public.png", visibility: .all) { completion in
            completion(pngData, nil)
            return nil
        }

        // Сохраняем в буфер обмена с современным API
        UIPasteboard.general.itemProviders = [itemProvider]

        // Вставляем индикатор с информацией о PNG
        let fileSizeKB = Double(pngData.count) / 1024.0
        let sizeText = fileSizeKB > 1 ? String(format: "%.1fKB", fileSizeKB) : "\(pngData.count)B"
        textDocumentProxy.insertText("🖼️ PNG (\(sizeText))")

        print("🎨 Image prepared with modern API (iOS 13+) - PNG size: \(sizeText)")
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

    private func returnToIslamicKeyboard() {
        // Возвращаем стандартную высоту клавиатуры
        updateKeyboardHeight(keyboardHeight)

        // Всегда возвращаемся к исламской клавиатуре
        currentMode = .islamic
        // Удаляем старую клавиатуру и создаем исламскую
        keyboardView.subviews.forEach { $0.removeFromSuperview() }
        createIslamicKeyboard()
    }

    private func updateKeyboardHeight(_ height: CGFloat) {
        // Обновляем constraint высоты клавиатуры
        for constraint in self.view.constraints {
            if constraint.firstAttribute == .height {
                constraint.constant = height
                break
            }
        }
        self.view.layoutIfNeeded()
        print("🎨 Updated keyboard height to: \(height)")
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

    @objc private func stickerSettingsChanged() {
        print("🎨 Sticker settings changed notification received")
        DispatchQueue.main.async {
            // Пересоздаем клавиатуру, чтобы обновить кнопку стикеров
            if self.currentMode == .islamic {
                self.createIslamicKeyboard()
            }
        }
    }

    @objc private func stickerSelectionChanged() {
        print("🎨 Sticker selection changed notification received")
        DispatchQueue.main.async {
            // Обновляем счетчик на кнопке стикеров
            if self.currentMode == .islamic {
                self.createIslamicKeyboard()
            }
        }
    }

    @objc private func stickerVisibilityChanged() {
        print("🎨 Sticker visibility changed notification received")
        DispatchQueue.main.async {
            // Пересоздаем клавиатуру, чтобы показать/скрыть кнопку стикеров
            if self.currentMode == .islamic {
                self.createIslamicKeyboard()
            }
        }
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

import UIKit

class KeyboardViewController: UIInputViewController {
    
    // MARK: - Properties
    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    private var languageButton: UIButton!
    private var nextKeyboardButton: UIButton!
    
    private let languageManager = KeyboardLanguageManager.shared
    private let phrasesManager = KeyboardPhrasesManager.shared
    
    private let keyboardHeight: CGFloat = 180
    private let buttonHeight: CGFloat = 40
    private let buttonSpacing: CGFloat = 8
    private let sideMargin: CGFloat = 8
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        setupScrollView()
        setupBottomControls()
        setupPhraseButtons()
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.backgroundColor = UIColor.clear
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sideMargin),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sideMargin),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = buttonSpacing
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupBottomControls() {
        languageButton = UIButton(type: .custom)
        languageButton.translatesAutoresizingMaskIntoConstraints = false
        languageButton.backgroundColor = UIColor(red: 0.68, green: 0.71, blue: 0.74, alpha: 1.0) // Серый фон как у служебных клавиш iOS
        languageButton.layer.cornerRadius = 6
        languageButton.layer.borderWidth = 0
        // Добавляем тень
        languageButton.layer.shadowColor = UIColor.black.cgColor
        languageButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        languageButton.layer.shadowOpacity = 0.2
        languageButton.layer.shadowRadius = 1
        languageButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        languageButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal) // Темно-серый текст
        languageButton.setAttributedTitle(nil, for: .normal)
        languageButton.titleLabel?.attributedText = nil
        languageButton.addTarget(self, action: #selector(languageButtonTapped), for: .touchUpInside)
        
        nextKeyboardButton = UIButton(type: .custom)
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        nextKeyboardButton.setTitle("🌐", for: .normal)
        nextKeyboardButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        nextKeyboardButton.backgroundColor = UIColor(red: 0.68, green: 0.71, blue: 0.74, alpha: 1.0) // Серый фон как у служебных клавиш iOS
        nextKeyboardButton.layer.cornerRadius = 6
        nextKeyboardButton.layer.borderWidth = 0
        // Добавляем тень
        nextKeyboardButton.layer.shadowColor = UIColor.black.cgColor
        nextKeyboardButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        nextKeyboardButton.layer.shadowOpacity = 0.2
        nextKeyboardButton.layer.shadowRadius = 1
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        view.addSubview(languageButton)
        view.addSubview(nextKeyboardButton)
        
        NSLayoutConstraint.activate([
            languageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sideMargin),
            languageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            languageButton.heightAnchor.constraint(equalToConstant: 32),
            languageButton.widthAnchor.constraint(equalToConstant: 60),
            
            nextKeyboardButton.trailingAnchor.constraint(equalTo: languageButton.leadingAnchor, constant: -8),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            nextKeyboardButton.heightAnchor.constraint(equalToConstant: 32),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 32)
        ])
        
        updateLanguageButton()
    }
    
    private func setupPhraseButtons() {
        print("🔄 KeyboardViewController: setupPhraseButtons called")
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let selectedPhrases = phrasesManager.selectedPhrases
        let currentLanguage = languageManager.currentLanguage
        
        print("📊 KeyboardViewController: Setting up \(selectedPhrases.count) phrase buttons")
        print("🌍 KeyboardViewController: Current language: \(currentLanguage)")
        
        var currentRowStack: UIStackView?
        
        for (index, phrase) in selectedPhrases.enumerated() {
            print("   \(index + 1). \(phrase.key) - \(phrase.arabic)")
            
            if index % 2 == 0 {
                currentRowStack = UIStackView()
                currentRowStack!.translatesAutoresizingMaskIntoConstraints = false
                currentRowStack!.axis = .horizontal
                currentRowStack!.spacing = buttonSpacing
                currentRowStack!.alignment = .fill
                currentRowStack!.distribution = .fillEqually
                
                stackView.addArrangedSubview(currentRowStack!)
                currentRowStack!.heightAnchor.constraint(equalToConstant: 50).isActive = true
            }
            
            let button = createPhraseButton(for: phrase, language: currentLanguage)
            currentRowStack!.addArrangedSubview(button)
        }
        
        if selectedPhrases.count % 2 == 1 {
            let spacerView = UIView()
            spacerView.backgroundColor = UIColor.clear
            currentRowStack!.addArrangedSubview(spacerView)
        }
        
        print("✅ KeyboardViewController: Phrase buttons setup completed")
    }
    
    private func createPhraseButton(for phrase: KeyboardIslamicPhrase, language: KeyboardLanguage) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Белый фон для кнопок фраз в стиле iOS
        button.backgroundColor = UIColor.white
        button.setBackgroundImage(nil, for: .normal)
        button.layer.cornerRadius = 8 // Меньший радиус как у iOS клавиатуры
        button.layer.borderWidth = 0 // Убираем границу
        // Добавляем тень для объема
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 1
        
        let displayText = phrase.displayText(for: language)
        
        // Полностью очищаем любые атрибуты и используем простой текст
        button.setAttributedTitle(nil, for: .normal)
        button.setAttributedTitle(nil, for: .highlighted)
        button.setAttributedTitle(nil, for: .selected)

        // Устанавливаем простой текст без атрибутов
        button.setTitle(displayText, for: .normal)
        button.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal) // Темно-серый текст
        button.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .highlighted)
        button.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .selected)

        // Настройки шрифта и label
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = .byWordWrapping

        // Принудительно убираем любые атрибуты текста
        button.titleLabel?.attributedText = nil
        
        button.addTarget(self, action: #selector(phraseButtonTapped(_:)), for: .touchUpInside)
        button.tag = phrasesManager.allPhrases.firstIndex(where: { $0.key == phrase.key }) ?? 0
        
        return button
    }
    
    // MARK: - Actions
    @objc private func phraseButtonTapped(_ sender: UIButton) {
        let phraseIndex = sender.tag
        let phrase = phrasesManager.allPhrases[phraseIndex]
        let currentLanguage = languageManager.currentLanguage
        
        let textToInsert = phrase.displayText(for: currentLanguage)
        textDocumentProxy.insertText(textToInsert)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func languageButtonTapped() {
        languageManager.toggleLanguage()
        updateLanguageButton()
        setupPhraseButtons()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Helper Methods
    private func refreshKeyboardData() {
        print("🔄 KeyboardViewController: refreshKeyboardData called")
        
        phrasesManager.refreshData()
        
        let selectedPhrases = phrasesManager.selectedPhrases
        print("📊 KeyboardViewController: Found \(selectedPhrases.count) selected phrases")
        for phrase in selectedPhrases {
            print("   - \(phrase.key): \(phrase.englishTransliteration)")
        }
        
        let newLanguage = KeyboardLanguageManager.shared.currentLanguage
        print("🌍 KeyboardViewController: Current language: \(newLanguage)")
        
        if newLanguage != languageManager.currentLanguage {
            print("🔄 KeyboardViewController: Language changed from \(languageManager.currentLanguage) to \(newLanguage)")
            languageManager.currentLanguage = newLanguage
            updateLanguageButton()
        }
        
        setupPhraseButtons()
        print("✅ KeyboardViewController: Refresh completed")
    }
    
    private func updateLanguageButton() {
        let currentLanguage = languageManager.currentLanguage
        let languageText = currentLanguage == .english ? "Eng" : "Рус"
        languageButton.setTitle(languageText, for: .normal)
        languageButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .normal) // Темно-серый текст
        languageButton.setAttributedTitle(nil, for: .normal)
        languageButton.titleLabel?.attributedText = nil
    }
    
    private func updateAppearance() {
        view.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0) // Светло-серый фон
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey
    }
}

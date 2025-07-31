//
//  LanguageManager.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI
import Foundation

// MARK: - Language Enum
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case russian = "ru"
    case kazakh = "kk"
    case arabic = "ar"
    case french = "fr"
    case german = "de"
    case chinese = "zh"
    case hindi = "hi"
    case kyrgyz = "ky"
    case uzbek = "uz"
    case korean = "ko"
    case urdu = "ur"
    case spanish = "es"
    case italian = "it"

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .russian:
            return "Русский"
        case .kazakh:
            return "Қазақша"
        case .arabic:
            return "العربية"
        case .french:
            return "Français"
        case .german:
            return "Deutsch"
        case .chinese:
            return "中文"
        case .hindi:
            return "हिन्दी"
        case .kyrgyz:
            return "Кыргызча"
        case .uzbek:
            return "O'zbekcha"
        case .korean:
            return "한국어"
        case .urdu:
            return "اردو"
        case .spanish:
            return "Español"
        case .italian:
            return "Italiano"
        }
    }

    var flag: String {
        switch self {
        case .english:
            return "🇺🇸"
        case .russian:
            return "🇷🇺"
        case .kazakh:
            return "🇰🇿"
        case .arabic:
            return "🇸🇦"
        case .french:
            return "🇫🇷"
        case .german:
            return "🇩🇪"
        case .chinese:
            return "🇨🇳"
        case .hindi:
            return "🇮🇳"
        case .kyrgyz:
            return "🇰🇬"
        case .uzbek:
            return "🇺🇿"
        case .korean:
            return "🇰🇷"
        case .urdu:
            return "🇵🇰"
        case .spanish:
            return "🇪🇸"
        case .italian:
            return "🇮🇹"
        }
    }

    var locale: Locale {
        return Locale(identifier: self.rawValue)
    }
}

// MARK: - Arabic Display Mode
enum ArabicDisplayMode: String, CaseIterable {
    case arabic = "arabic"           // Показывать арабский текст
    case englishTranslation = "english_translation"  // Показывать английский перевод

    var displayName: String {
        switch self {
        case .arabic:
            return NSLocalizedString("arabic_display_arabic", comment: "")
        case .englishTranslation:
            return NSLocalizedString("arabic_display_english", comment: "")
        }
    }
}

// MARK: - Language Manager
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: AppLanguage {
        didSet {
            saveLanguage()
            updateLocale()
        }
    }

    @Published var arabicLanguagePreference: AppLanguage? {
        didSet {
            saveArabicLanguagePreference()
        }
    }

    @Published var arabicDuaLanguagePreference: AppLanguage? {
        didSet {
            saveArabicDuaLanguagePreference()
        }
    }

    // Настройка для арабского языка: показывать арабский текст или английский перевод
    @Published var arabicDisplayMode: ArabicDisplayMode {
        didSet {
            saveArabicDisplayMode()
        }
    }

    private let userDefaults: UserDefaults
    private let languageKey = "selected_language"
    private let arabicLanguagePreferenceKey = "arabic_language_preference"
    private let arabicDuaLanguagePreferenceKey = "arabic_dua_language_preference"
    private let arabicDisplayModeKey = "arabic_display_mode"
    
    private init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard

        // Load saved language or default to English
        if let savedLanguage = userDefaults.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Try to detect system language
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = AppLanguage(rawValue: systemLanguage) ?? .english
        }

        // Load Arabic language preference
        if let savedArabicLang = userDefaults.string(forKey: arabicLanguagePreferenceKey),
           let arabicLang = AppLanguage(rawValue: savedArabicLang) {
            self.arabicLanguagePreference = arabicLang
        } else {
            self.arabicLanguagePreference = nil // По умолчанию арабский отключен
        }

        // Load Arabic Dua language preference
        if let savedArabicDuaLang = userDefaults.string(forKey: arabicDuaLanguagePreferenceKey),
           let arabicDuaLang = AppLanguage(rawValue: savedArabicDuaLang) {
            self.arabicDuaLanguagePreference = arabicDuaLang
        } else {
            self.arabicDuaLanguagePreference = nil // По умолчанию арабский отключен
        }

        // Load Arabic display mode
        if let savedArabicDisplayMode = userDefaults.string(forKey: arabicDisplayModeKey),
           let arabicDisplayMode = ArabicDisplayMode(rawValue: savedArabicDisplayMode) {
            self.arabicDisplayMode = arabicDisplayMode
        } else {
            self.arabicDisplayMode = .arabic // По умолчанию показываем арабский текст
        }

        updateLocale()
    }
    
    private func saveLanguage() {
        userDefaults.set(currentLanguage.rawValue, forKey: languageKey)
        userDefaults.synchronize() // Принудительная синхронизация для App Groups
        print("🔄 LanguageManager: Language saved: \(currentLanguage.rawValue)")
    }

    private func saveArabicLanguagePreference() {
        if let arabicLang = arabicLanguagePreference {
            userDefaults.set(arabicLang.rawValue, forKey: arabicLanguagePreferenceKey)
        } else {
            userDefaults.removeObject(forKey: arabicLanguagePreferenceKey)
        }
        userDefaults.synchronize() // Принудительная синхронизация для App Groups
        print("🔄 LanguageManager: Arabic language preference saved: \(arabicLanguagePreference?.rawValue ?? "none")")
    }

    private func saveArabicDuaLanguagePreference() {
        if let arabicDuaLang = arabicDuaLanguagePreference {
            userDefaults.set(arabicDuaLang.rawValue, forKey: arabicDuaLanguagePreferenceKey)
        } else {
            userDefaults.removeObject(forKey: arabicDuaLanguagePreferenceKey)
        }
        userDefaults.synchronize() // Принудительная синхронизация для App Groups
        print("🔄 LanguageManager: Arabic Dua language preference saved: \(arabicDuaLanguagePreference?.rawValue ?? "none")")
    }

    private func saveArabicDisplayMode() {
        userDefaults.set(arabicDisplayMode.rawValue, forKey: arabicDisplayModeKey)
        userDefaults.synchronize() // Принудительная синхронизация для App Groups
        print("🔄 LanguageManager: Arabic display mode saved: \(arabicDisplayMode.rawValue)")
    }
    
    private func updateLocale() {
        UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }

    func setArabicLanguagePreference(_ language: AppLanguage?) {
        arabicLanguagePreference = language
    }

    func setArabicDuaLanguagePreference(_ language: AppLanguage?) {
        arabicDuaLanguagePreference = language
    }

    func setArabicDisplayMode(_ mode: ArabicDisplayMode) {
        arabicDisplayMode = mode
    }

    // Проверяет, нужно ли использовать арабский текст для данного языка
    func shouldUseArabicForLanguage(_ language: AppLanguage) -> Bool {
        return arabicLanguagePreference == language
    }

    // Проверяет, нужно ли использовать арабский текст для дуа для данного языка
    func shouldUseArabicForDuaLanguage(_ language: AppLanguage) -> Bool {
        return arabicDuaLanguagePreference == language
    }

    // Для обратной совместимости
    var showArabicInKeyboard: Bool {
        return arabicLanguagePreference != nil
    }

    // Проверяет, включен ли арабский для дуа
    var showArabicDuaInKeyboard: Bool {
        return arabicDuaLanguagePreference != nil
    }
    
    // Helper method to get localized string
    func localizedString(for key: String) -> String {
        let bundle = Bundle.main
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

// MARK: - Localization Helper
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - SwiftUI Environment
struct LanguageEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppLanguage = .english
}

extension EnvironmentValues {
    var language: AppLanguage {
        get { self[LanguageEnvironmentKey.self] }
        set { self[LanguageEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Extension for Localization
extension View {
    func environmentLanguage(_ language: AppLanguage) -> some View {
        self.environment(\.language, language)
            .environment(\.locale, language.locale)
    }
}

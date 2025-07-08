//
//  KeyboardLanguageManager.swift
//  KeyboardApp
//
//  Created by Zainab on 19.06.2025.
//

import Foundation

// MARK: - Language Enum for Keyboard
enum KeyboardLanguage: String, CaseIterable, Codable {
    case english = "en"
    case russian = "ru"
    case kazakh = "kk"
    case arabic = "ar"

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
        }
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

// MARK: - Keyboard Language Manager
class KeyboardLanguageManager {
    static let shared = KeyboardLanguageManager()
    
    private let userDefaults: UserDefaults
    private let languageKey = "selected_language" // Используем тот же ключ, что и основное приложение
    private let availableLanguagesKey = "keyboard_available_languages"
    private let arabicLanguagePreferenceKey = "arabic_language_preference"
    private let arabicDuaLanguagePreferenceKey = "arabic_dua_language_preference"
    private let arabicDisplayModeKey = "arabic_display_mode"

    var currentLanguage: KeyboardLanguage {
        didSet {
            saveLanguage()
        }
    }

    var arabicLanguagePreference: KeyboardLanguage? {
        if let savedArabicLang = userDefaults.string(forKey: arabicLanguagePreferenceKey),
           let arabicLang = KeyboardLanguage(rawValue: savedArabicLang) {
            return arabicLang
        }
        return nil
    }

    var arabicDuaLanguagePreference: KeyboardLanguage? {
        if let savedArabicDuaLang = userDefaults.string(forKey: arabicDuaLanguagePreferenceKey),
           let arabicDuaLang = KeyboardLanguage(rawValue: savedArabicDuaLang) {
            return arabicDuaLang
        }
        return nil
    }

    var arabicDisplayMode: ArabicDisplayMode {
        if let savedArabicDisplayMode = userDefaults.string(forKey: arabicDisplayModeKey),
           let arabicDisplayMode = ArabicDisplayMode(rawValue: savedArabicDisplayMode) {
            return arabicDisplayMode
        }
        return .arabic // По умолчанию показываем арабский текст
    }

    // Проверяет, нужно ли использовать арабский текст для текущего языка
    func shouldUseArabicForCurrentLanguage() -> Bool {
        return arabicLanguagePreference == currentLanguage
    }

    // Проверяет, нужно ли использовать арабский текст для дуа для текущего языка
    func shouldUseArabicForDuaCurrentLanguage() -> Bool {
        return arabicDuaLanguagePreference == currentLanguage
    }

    // Для обратной совместимости
    var showArabicInKeyboard: Bool {
        return arabicLanguagePreference != nil
    }

    // Проверяет, включен ли арабский для дуа
    var showArabicDuaInKeyboard: Bool {
        return arabicDuaLanguagePreference != nil
    }

    var availableLanguages: [KeyboardLanguage] {
        if let languageData = userDefaults.data(forKey: availableLanguagesKey),
           let languageStrings = try? JSONDecoder().decode([String].self, from: languageData) {
            let keyboardLanguages = languageStrings.compactMap { KeyboardLanguage(rawValue: $0) }
            return keyboardLanguages.isEmpty ? [.english, .russian] : keyboardLanguages
        }
        return [.english, .russian] // По умолчанию оба языка
    }

    // Проверяем, нужно ли показывать кнопку переключения языков
    var shouldShowLanguageToggle: Bool {
        return availableLanguages.count > 1
    }
    
    private init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
        
        // Load saved language or default to English
        if let savedLanguage = userDefaults.string(forKey: languageKey),
           let language = KeyboardLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = .english
        }
    }
    
    private func saveLanguage() {
        userDefaults.set(currentLanguage.rawValue, forKey: languageKey)
        userDefaults.synchronize()
    }
    
    func toggleLanguage() {
        let available = availableLanguages
        guard available.count > 1 else { return } // Нечего переключать

        if let currentIndex = available.firstIndex(of: currentLanguage) {
            let nextIndex = (currentIndex + 1) % available.count
            currentLanguage = available[nextIndex]
        } else {
            currentLanguage = available.first ?? .english
        }
    }

    // Принудительно обновляем язык из основного приложения
    func refreshLanguageFromMainApp() {
        // Сначала проверяем доступные языки и убеждаемся, что текущий язык доступен
        let available = availableLanguages
        if !available.contains(currentLanguage) {
            print("🔄 KeyboardLanguageManager: Current language not available, switching to: \(available.first ?? .english)")
            currentLanguage = available.first ?? .english
        }

        // Затем проверяем сохраненный язык из основного приложения
        if let savedLanguage = userDefaults.string(forKey: languageKey),
           let language = KeyboardLanguage(rawValue: savedLanguage) {
            if language != currentLanguage && available.contains(language) {
                print("🔄 KeyboardLanguageManager: Language updated from main app: \(language)")
                currentLanguage = language
            }
        }

        print("🌍 KeyboardLanguageManager: Available languages: \(available)")
        print("🌍 KeyboardLanguageManager: Current language: \(currentLanguage)")
        print("🔘 KeyboardLanguageManager: Should show toggle: \(shouldShowLanguageToggle)")
    }
}

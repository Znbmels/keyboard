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
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .russian:
            return "Русский"
        }
    }
    
    var flag: String {
        switch self {
        case .english:
            return "🇺🇸"
        case .russian:
            return "🇷🇺"
        }
    }
}

// MARK: - Keyboard Language Manager
class KeyboardLanguageManager {
    static let shared = KeyboardLanguageManager()
    
    private let userDefaults: UserDefaults
    private let languageKey = "keyboard_selected_language"
    private let availableLanguagesKey = "keyboard_available_languages"

    var currentLanguage: KeyboardLanguage {
        didSet {
            saveLanguage()
        }
    }

    var availableLanguages: [KeyboardLanguage] {
        if let languageData = userDefaults.data(forKey: availableLanguagesKey),
           let languages = try? JSONDecoder().decode([KeyboardLanguage].self, from: languageData) {
            return languages.isEmpty ? [.english, .russian] : languages
        }
        return [.english, .russian] // По умолчанию оба языка
    }
    
    private init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.org.mels.keyboard.muslim") ?? UserDefaults.standard
        
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
}

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
    
    var locale: Locale {
        return Locale(identifier: self.rawValue)
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
    
    private let userDefaults: UserDefaults
    private let languageKey = "selected_language"
    
    private init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.org.mels.keyboard.muslim") ?? UserDefaults.standard

        // Load saved language or default to English
        if let savedLanguage = userDefaults.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Try to detect system language
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = AppLanguage(rawValue: systemLanguage) ?? .english
        }
        updateLocale()
    }
    
    private func saveLanguage() {
        userDefaults.set(currentLanguage.rawValue, forKey: languageKey)
    }
    
    private func updateLocale() {
        UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
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

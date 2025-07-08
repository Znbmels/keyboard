//
//  KeyboardColorManager.swift
//  KeyboardApp
//
//  Created by Zainab on 02.07.2025.
//

import UIKit

// MARK: - Keyboard Color Theme
struct KeyboardColorTheme {
    let id: String
    let name: String
    let color: UIColor
    let isDefault: Bool
    
    static let availableThemes: [KeyboardColorTheme] = [
        KeyboardColorTheme(
            id: "islamic_green",
            name: "Islamic Green",
            color: UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0),
            isDefault: true
        ),
        KeyboardColorTheme(
            id: "ocean_blue",
            name: "Ocean Blue",
            color: UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "royal_purple",
            name: "Royal Purple",
            color: UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "golden_amber",
            name: "Golden Amber",
            color: UIColor(red: 0.8, green: 0.6, blue: 0.0, alpha: 1.0),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "elegant_gray",
            name: "Elegant Gray",
            color: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "pure_white",
            name: "Pure White",
            color: UIColor.white,
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "soft_pink",
            name: "Soft Pink",
            color: UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "deep_teal",
            name: "Deep Teal",
            color: UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "warm_orange",
            name: "Warm Orange",
            color: UIColor(red: 0.9, green: 0.5, blue: 0.1, alpha: 1.0),
            isDefault: false
        )
    ]
}

// MARK: - Keyboard Color Manager
class KeyboardColorManager {
    static let shared = KeyboardColorManager()
    
    var selectedTheme: KeyboardColorTheme {
        didSet {
            saveSelectedTheme()
        }
    }
    
    private let userDefaults: UserDefaults
    private let selectedThemeKey = "selected_keyboard_theme"
    
    private init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
        
        // Загружаем сохраненную тему или используем по умолчанию
        if let savedThemeId = userDefaults.string(forKey: selectedThemeKey),
           let savedTheme = KeyboardColorTheme.availableThemes.first(where: { $0.id == savedThemeId }) {
            self.selectedTheme = savedTheme
        } else {
            self.selectedTheme = KeyboardColorTheme.availableThemes.first(where: { $0.isDefault }) ?? KeyboardColorTheme.availableThemes[0]
        }
        
        print("🎨 KeyboardColorManager: Initialized with theme: \(selectedTheme.id)")
    }
    
    private func saveSelectedTheme() {
        userDefaults.set(selectedTheme.id, forKey: selectedThemeKey)
        userDefaults.synchronize()
        print("🎨 KeyboardColorManager: Theme saved: \(selectedTheme.id)")
    }
    
    func setTheme(_ theme: KeyboardColorTheme) {
        selectedTheme = theme
    }

    func reloadThemeFromUserDefaults() {
        if let savedThemeId = userDefaults.string(forKey: selectedThemeKey),
           let savedTheme = KeyboardColorTheme.availableThemes.first(where: { $0.id == savedThemeId }) {
            selectedTheme = savedTheme
            print("🎨 KeyboardColorManager: Theme reloaded from UserDefaults: \(savedTheme.id)")
        }
    }
    
    // Получить цвет для кнопок клавиатуры
    var keyboardButtonColor: UIColor {
        return selectedTheme.color
    }
    
    // Получить цвет текста для кнопок (белый для темных цветов, черный для светлых)
    var keyboardButtonTextColor: UIColor {
        if selectedTheme.id == "pure_white" || selectedTheme.id == "golden_amber" || selectedTheme.id == "warm_orange" {
            return .black
        } else {
            return .white
        }
    }
    
    // Получить цвет для выделенной кнопки (немного темнее основного цвета)
    var selectedButtonColor: UIColor {
        switch selectedTheme.id {
        case "islamic_green":
            return UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        case "ocean_blue":
            return UIColor(red: 0.0, green: 0.3, blue: 0.7, alpha: 1.0)
        case "royal_purple":
            return UIColor(red: 0.3, green: 0.1, blue: 0.7, alpha: 1.0)
        case "golden_amber":
            return UIColor(red: 0.7, green: 0.5, blue: 0.0, alpha: 1.0)
        case "elegant_gray":
            return UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        case "pure_white":
            return UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        case "soft_pink":
            return UIColor(red: 0.8, green: 0.3, blue: 0.5, alpha: 1.0)
        case "deep_teal":
            return UIColor(red: 0.0, green: 0.4, blue: 0.4, alpha: 1.0)
        case "warm_orange":
            return UIColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0)
        default:
            return selectedTheme.color
        }
    }
}

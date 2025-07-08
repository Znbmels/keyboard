//
//  KeyboardColorManager.swift
//  Keyboard
//
//  Created by Zainab on 02.07.2025.
//

import SwiftUI
import Foundation

// MARK: - Keyboard Color Theme
struct KeyboardColorTheme {
    let id: String
    let name: LocalizedStringKey
    let color: Color
    let isDefault: Bool
    
    static let availableThemes: [KeyboardColorTheme] = [
        KeyboardColorTheme(
            id: "islamic_green",
            name: "color_islamic_green",
            color: .islamicGreen,
            isDefault: true
        ),
        KeyboardColorTheme(
            id: "ocean_blue",
            name: "color_ocean_blue",
            color: Color(red: 0.0, green: 0.4, blue: 0.8),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "royal_purple",
            name: "color_royal_purple",
            color: Color(red: 0.4, green: 0.2, blue: 0.8),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "golden_amber",
            name: "color_golden_amber",
            color: Color(red: 0.8, green: 0.6, blue: 0.0),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "elegant_gray",
            name: "color_elegant_gray",
            color: Color(red: 0.4, green: 0.4, blue: 0.4),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "pure_white",
            name: "color_pure_white",
            color: Color.white,
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "soft_pink",
            name: "color_soft_pink",
            color: Color(red: 0.9, green: 0.4, blue: 0.6),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "deep_teal",
            name: "color_deep_teal",
            color: Color(red: 0.0, green: 0.5, blue: 0.5),
            isDefault: false
        ),
        KeyboardColorTheme(
            id: "warm_orange",
            name: "color_warm_orange",
            color: Color(red: 0.9, green: 0.5, blue: 0.1),
            isDefault: false
        )
    ]
}

// MARK: - Keyboard Color Manager
class KeyboardColorManager: ObservableObject {
    static let shared = KeyboardColorManager()
    
    @Published var selectedTheme: KeyboardColorTheme {
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
    
    // Получить цвет для кнопок клавиатуры
    var keyboardButtonColor: Color {
        return selectedTheme.color
    }
    
    // Получить цвет текста для кнопок (белый для темных цветов, черный для светлых)
    var keyboardButtonTextColor: Color {
        if selectedTheme.id == "pure_white" || selectedTheme.id == "golden_amber" || selectedTheme.id == "warm_orange" {
            return .black
        } else {
            return .white
        }
    }
    
    // Получить цвет для выделенной кнопки (немного темнее основного цвета)
    var selectedButtonColor: Color {
        switch selectedTheme.id {
        case "islamic_green":
            return Color(red: 0.0, green: 0.4, blue: 0.0)
        case "ocean_blue":
            return Color(red: 0.0, green: 0.3, blue: 0.7)
        case "royal_purple":
            return Color(red: 0.3, green: 0.1, blue: 0.7)
        case "golden_amber":
            return Color(red: 0.7, green: 0.5, blue: 0.0)
        case "elegant_gray":
            return Color(red: 0.3, green: 0.3, blue: 0.3)
        case "pure_white":
            return Color(red: 0.9, green: 0.9, blue: 0.9)
        case "soft_pink":
            return Color(red: 0.8, green: 0.3, blue: 0.5)
        case "deep_teal":
            return Color(red: 0.0, green: 0.4, blue: 0.4)
        case "warm_orange":
            return Color(red: 0.8, green: 0.4, blue: 0.0)
        default:
            return selectedTheme.color
        }
    }
}

// MARK: - Color Extensions
extension Color {
    // Дополнительные исламские цвета
    static let oceanBlue = Color(red: 0.0, green: 0.4, blue: 0.8)
    static let royalPurple = Color(red: 0.4, green: 0.2, blue: 0.8)
    static let goldenAmber = Color(red: 0.8, green: 0.6, blue: 0.0)
    static let elegantGray = Color(red: 0.4, green: 0.4, blue: 0.4)
}

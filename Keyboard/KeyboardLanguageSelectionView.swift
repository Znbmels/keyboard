//
//  KeyboardLanguageSelectionView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

// MARK: - Keyboard Language Enum (для основного приложения)
enum KeyboardLanguageOption: String, CaseIterable, Codable {
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

    // Создание из строки
    static func fromRawValue(_ rawValue: String) -> KeyboardLanguageOption? {
        switch rawValue {
        case "en":
            return .english
        case "ru":
            return .russian
        case "kk":
            return .kazakh
        case "ar":
            return .arabic
        default:
            return nil
        }
    }
}

struct KeyboardLanguageSelectionView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedLanguages: Set<KeyboardLanguageOption> = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("keyboard_languages_title")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("keyboard_languages_subtitle")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Language Options
                    VStack(spacing: 16) {
                        LanguageOptionRow(
                            language: .english,
                            isSelected: selectedLanguages.contains(.english),
                            onToggle: { toggleLanguage(.english) }
                        )

                        LanguageOptionRow(
                            language: .russian,
                            isSelected: selectedLanguages.contains(.russian),
                            onToggle: { toggleLanguage(.russian) }
                        )

                        LanguageOptionRow(
                            language: .kazakh,
                            isSelected: selectedLanguages.contains(.kazakh),
                            onToggle: { toggleLanguage(.kazakh) }
                        )

                        LanguageOptionRow(
                            language: .arabic,
                            isSelected: selectedLanguages.contains(.arabic),
                            onToggle: { toggleLanguage(.arabic) }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: saveSelection) {
                        Text("save_selection")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.islamicGreen)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    .disabled(selectedLanguages.isEmpty)
                    .opacity(selectedLanguages.isEmpty ? 0.5 : 1.0)
                }
            }
            .navigationTitle("keyboard_settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.islamicGreen)
                }
            }
        }
        .onAppear {
            loadCurrentSelection()
        }
    }
    
    private func toggleLanguage(_ language: KeyboardLanguageOption) {
        if selectedLanguages.contains(language) {
            selectedLanguages.remove(language)
        } else {
            selectedLanguages.insert(language)
        }
    }

    private func loadCurrentSelection() {
        // Загружаем текущие выбранные языки из UserDefaults
        let defaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
        if let languageData = defaults.data(forKey: "keyboard_available_languages"),
           let languageStrings = try? JSONDecoder().decode([String].self, from: languageData) {
            let languages = languageStrings.compactMap { rawValue in
                KeyboardLanguageOption.fromRawValue(rawValue)
            }
            selectedLanguages = Set(languages)
        } else {
            // По умолчанию включаем оба языка
            selectedLanguages = [.english, .russian]
        }
    }

    private func saveSelection() {
        // Сохраняем выбранные языки как строки
        let defaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
        let languageStrings = Array(selectedLanguages).map { $0.rawValue }

        if let encoded = try? JSONEncoder().encode(languageStrings) {
            defaults.set(encoded, forKey: "keyboard_available_languages")
            defaults.synchronize()
        }

        dismiss()
    }
}

struct LanguageOptionRow: View {
    let language: KeyboardLanguageOption
    let isSelected: Bool
    let onToggle: () -> Void

    private var backgroundShape: some View {
        let fillColor = isSelected ? Color.islamicGreen.opacity(0.1) : Color.white.opacity(0.05)
        let strokeColor = isSelected ? Color.islamicGreen.opacity(0.3) : Color.white.opacity(0.1)

        return RoundedRectangle(cornerRadius: 16)
            .fill(fillColor)
            .stroke(strokeColor, lineWidth: 1)
    }

    private var buttonText: String {
        switch language {
        case .english:
            return "Eng"
        case .russian:
            return "Рус"
        case .kazakh:
            return "Қаз"
        case .arabic:
            return "عرب"
        }
    }

    private var backgroundColor: Color {
        Color(red: 0.9, green: 0.9, blue: 0.9)
    }

    private var borderColor: Color {
        Color(red: 0.7, green: 0.7, blue: 0.7)
    }

    private var transliterationText: String {
        switch language {
        case .english:
            return "English transliteration"
        case .russian:
            return "Русская транслитерация"
        case .kazakh:
            return "Қазақша транслитерация"
        case .arabic:
            return "النسخ العربي"
        }
    }

    private var checkboxStrokeColor: Color {
        isSelected ? Color.islamicGreen : Color.white.opacity(0.3)
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Language Preview Button
                VStack(spacing: 8) {
                    Text(buttonText)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(width: 80, height: 44)
                        .background(backgroundColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderColor, lineWidth: 1)
                        )
                    
                    Text(language.displayName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Language Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)

                    Text(transliterationText)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Selection Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(checkboxStrokeColor, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.islamicGreen)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(backgroundShape)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    KeyboardLanguageSelectionView()
}

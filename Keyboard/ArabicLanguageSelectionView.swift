//
//  ArabicLanguageSelectionView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct ArabicLanguageSelectionView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedLanguage: AppLanguage?
    @Environment(\.dismiss) private var dismiss
    
    let onLanguageSelected: (AppLanguage?) -> Void
    
    init(selectedLanguage: AppLanguage?, onLanguageSelected: @escaping (AppLanguage?) -> Void) {
        self._selectedLanguage = State(initialValue: selectedLanguage)
        self.onLanguageSelected = onLanguageSelected
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("arabic_language_selection_title")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("arabic_language_selection_subtitle")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Language Options
                    VStack(spacing: 16) {
                        // Disabled Option
                        ArabicLanguageOptionRow(
                            language: nil,
                            isSelected: selectedLanguage == nil,
                            onSelect: { selectedLanguage = nil }
                        )
                        
                        // English Option
                        ArabicLanguageOptionRow(
                            language: .english,
                            isSelected: selectedLanguage == .english,
                            onSelect: { selectedLanguage = .english }
                        )
                        
                        // Russian Option
                        ArabicLanguageOptionRow(
                            language: .russian,
                            isSelected: selectedLanguage == .russian,
                            onSelect: { selectedLanguage = .russian }
                        )

                        // Kazakh Option
                        ArabicLanguageOptionRow(
                            language: .kazakh,
                            isSelected: selectedLanguage == .kazakh,
                            onSelect: { selectedLanguage = .kazakh }
                        )

                        // Arabic Option
                        ArabicLanguageOptionRow(
                            language: .arabic,
                            isSelected: selectedLanguage == .arabic,
                            onSelect: { selectedLanguage = .arabic }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: {
                        onLanguageSelected(selectedLanguage)
                        dismiss()
                    }) {
                        HStack(spacing: 12) {
                            Text("save_selection")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "checkmark")
                                .font(.title3)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.islamicGreen)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                    .foregroundColor(.islamicGreen)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("arabic_language_selection_title")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .environmentLanguage(languageManager.currentLanguage)
    }
}

struct ArabicLanguageOptionRow: View {
    let language: AppLanguage?
    let isSelected: Bool
    let onSelect: () -> Void
    
    private var backgroundShape: some View {
        let fillColor = isSelected ? Color.islamicGreen.opacity(0.1) : Color.white.opacity(0.05)
        let strokeColor = isSelected ? Color.islamicGreen.opacity(0.3) : Color.white.opacity(0.1)
        
        return RoundedRectangle(cornerRadius: 16)
            .fill(fillColor)
            .stroke(strokeColor, lineWidth: 1)
    }
    
    private var displayName: String {
        if let language = language {
            return language.displayName
        } else {
            return NSLocalizedString("arabic_disabled", comment: "")
        }
    }
    
    private var description: String {
        if let language = language {
            switch language {
            case .english:
                return NSLocalizedString("arabic_english_description", comment: "")
            case .russian:
                return NSLocalizedString("arabic_russian_description", comment: "")
            case .kazakh:
                return NSLocalizedString("arabic_kazakh_description", comment: "")
            case .arabic:
                return NSLocalizedString("arabic_arabic_description", comment: "")
            }
        } else {
            return NSLocalizedString("arabic_disabled_description", comment: "")
        }
    }
    
    private var exampleText: String {
        if let language = language {
            switch language {
            case .english:
                return "Bismillah → بسم الله"
            case .russian:
                return "Бисмиллях → بسم الله"
            case .kazakh:
                return "Бисмиллях → بسم الله"
            case .arabic:
                return "بسم الله → بسم الله"
            }
        } else {
            return "Bismillah → Bismillah"
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Selection Indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.islamicGreen : Color.clear)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.islamicGreen : Color.white.opacity(0.3), lineWidth: 2)
                        )
                    
                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Language Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(exampleText)
                        .font(.caption)
                        .foregroundColor(.islamicGreen)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
            }
            .padding(16)
            .background(backgroundShape)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ArabicLanguageSelectionView(selectedLanguage: .english) { _ in }
}

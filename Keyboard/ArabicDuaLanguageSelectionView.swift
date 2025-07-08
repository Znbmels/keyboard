//
//  ArabicDuaLanguageSelectionView.swift
//  Keyboard
//
//  Created by Zainab on 07.07.2025.
//

import SwiftUI

struct ArabicDuaLanguageSelectionView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let selectedLanguage: AppLanguage?
    let onLanguageSelected: (AppLanguage?) -> Void
    
    @State private var tempSelection: AppLanguage?
    
    init(selectedLanguage: AppLanguage?, onLanguageSelected: @escaping (AppLanguage?) -> Void) {
        self.selectedLanguage = selectedLanguage
        self.onLanguageSelected = onLanguageSelected
        self._tempSelection = State(initialValue: selectedLanguage)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("arabic_dua_language_selection_title")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("arabic_dua_language_selection_description")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Language Options
                        VStack(spacing: 16) {
                            ArabicDuaLanguageOptionView(
                                language: nil,
                                isSelected: tempSelection == nil,
                                onTap: { tempSelection = nil }
                            )
                            
                            ArabicDuaLanguageOptionView(
                                language: .english,
                                isSelected: tempSelection == .english,
                                onTap: { tempSelection = .english }
                            )
                            
                            ArabicDuaLanguageOptionView(
                                language: .russian,
                                isSelected: tempSelection == .russian,
                                onTap: { tempSelection = .russian }
                            )

                            ArabicDuaLanguageOptionView(
                                language: .kazakh,
                                isSelected: tempSelection == .kazakh,
                                onTap: { tempSelection = .kazakh }
                            )

                            ArabicDuaLanguageOptionView(
                                language: .arabic,
                                isSelected: tempSelection == .arabic,
                                onTap: { tempSelection = .arabic }
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Save Button
                        Button(action: {
                            onLanguageSelected(tempSelection)
                            dismiss()
                        }) {
                            Text("save")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.islamicGreen)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }
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
                    Text("arabic_dua_language_selection_title")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .environmentLanguage(languageManager.currentLanguage)
    }
}

struct ArabicDuaLanguageOptionView: View {
    let language: AppLanguage?
    let isSelected: Bool
    let onTap: () -> Void
    
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
                return NSLocalizedString("arabic_dua_english_description", comment: "")
            case .russian:
                return NSLocalizedString("arabic_dua_russian_description", comment: "")
            case .kazakh:
                return NSLocalizedString("arabic_dua_kazakh_description", comment: "")
            case .arabic:
                return NSLocalizedString("arabic_dua_arabic_description", comment: "")
            }
        } else {
            return NSLocalizedString("arabic_dua_disabled_description", comment: "")
        }
    }
    
    private var exampleText: String {
        if let language = language {
            switch language {
            case .english:
                return "For Health → اللهم اشفه شفاءً لا يغادر سقماً"
            case .russian:
                return "За здоровье → اللهم اشفه شفاءً لا يغادر سقماً"
            case .kazakh:
                return "Денсаулық үшін → اللهم اشفه شفاءً لا يغادر سقماً"
            case .arabic:
                return "للصحة → اللهم اشفه شفاءً لا يغادر سقماً"
            }
        } else {
            return "For Health → O Allah, heal him with a healing that leaves no illness"
        }
    }
    
    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(isSelected ? 0.15 : 0.08),
                        Color.white.opacity(isSelected ? 0.08 : 0.03)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .stroke(
                isSelected ? Color.islamicGreen : Color.white.opacity(0.2),
                lineWidth: isSelected ? 2 : 1
            )
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection Indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.islamicGreen : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.islamicGreen : Color.white.opacity(0.3), lineWidth: 2)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
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
    ArabicDuaLanguageSelectionView(selectedLanguage: .english) { _ in }
}

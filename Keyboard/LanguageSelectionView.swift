//
//  LanguageSelectionView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct LanguageSelectionView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedLanguage: AppLanguage = .english
    @Environment(\.dismiss) private var dismiss
    
    let onLanguageSelected: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title Section
                VStack(spacing: 16) {
                    Text("language_selection_title")
                        .amiriQuranBoldFont(size: 32)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("language_selection_subtitle")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Language Options
                VStack(spacing: 20) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        LanguageOptionView(
                            language: language,
                            isSelected: selectedLanguage == language
                        ) {
                            selectedLanguage = language
                        }
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    languageManager.setLanguage(selectedLanguage)
                    onLanguageSelected()
                }) {
                    HStack(spacing: 12) {
                        Text("language_continue")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.title3)
                    }
                    .foregroundColor(.black)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.islamicGreen)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .environmentLanguage(selectedLanguage)
    }
}

struct LanguageOptionView: View {
    let language: AppLanguage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Flag
                Text(language.flag)
                    .font(.system(size: 32))
                
                // Language Name
                Text(language.displayName)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Selection Indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.islamicGreen : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isSelected ? Color.islamicGreen : Color.white.opacity(0.3), lineWidth: 2)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.islamicGreen.opacity(0.15) : Color.white.opacity(0.05))
                    .stroke(isSelected ? Color.islamicGreen : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    LanguageSelectionView {
        print("Language selected")
    }
}

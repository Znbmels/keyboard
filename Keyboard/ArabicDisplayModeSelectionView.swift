//
//  ArabicDisplayModeSelectionView.swift
//  Keyboard
//
//  Created by Zainab on 07.07.2025.
//

import SwiftUI

struct ArabicDisplayModeSelectionView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedMode: ArabicDisplayMode
    @Environment(\.dismiss) private var dismiss
    
    let onModeSelected: (ArabicDisplayMode) -> Void
    
    init(selectedMode: ArabicDisplayMode, onModeSelected: @escaping (ArabicDisplayMode) -> Void) {
        self._selectedMode = State(initialValue: selectedMode)
        self.onModeSelected = onModeSelected
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("arabic_display_mode_title")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("arabic_display_mode_subtitle")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Mode Options
                    VStack(spacing: 16) {
                        // Arabic Text Option
                        ArabicDisplayModeOptionRow(
                            mode: .arabic,
                            isSelected: selectedMode == .arabic,
                            onSelect: { selectedMode = .arabic }
                        )
                        
                        // English Translation Option
                        ArabicDisplayModeOptionRow(
                            mode: .englishTranslation,
                            isSelected: selectedMode == .englishTranslation,
                            onSelect: { selectedMode = .englishTranslation }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: {
                        onModeSelected(selectedMode)
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
                    Text("arabic_display_mode_title")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .environmentLanguage(languageManager.currentLanguage)
    }
}

struct ArabicDisplayModeOptionRow: View {
    let mode: ArabicDisplayMode
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
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
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Mode Title
                    Text(mode.displayName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    // Mode Description
                    Text(modeDescription)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                    
                    // Example Text
                    Text(exampleText)
                        .font(.subheadline)
                        .foregroundColor(.islamicGreen)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(20)
            .background(backgroundShape)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var modeDescription: String {
        switch mode {
        case .arabic:
            return NSLocalizedString("arabic_display_arabic_description", comment: "")
        case .englishTranslation:
            return NSLocalizedString("arabic_display_english_description", comment: "")
        }
    }
    
    private var exampleText: String {
        switch mode {
        case .arabic:
            return "بسم الله"
        case .englishTranslation:
            return "In the name of Allah"
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
}

#Preview {
    ArabicDisplayModeSelectionView(selectedMode: .arabic) { _ in }
}

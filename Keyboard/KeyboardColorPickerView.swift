//
//  KeyboardColorPickerView.swift
//  Keyboard
//
//  Created by Zainab on 02.07.2025.
//

import SwiftUI

struct KeyboardColorPickerView: View {
    @StateObject private var colorManager = KeyboardColorManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedTheme: KeyboardColorTheme
    @State private var showSavedMessage = false

    init() {
        _selectedTheme = State(initialValue: KeyboardColorManager.shared.selectedTheme)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Text("keyboard_colors_title")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("keyboard_colors_subtitle")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Keyboard Preview with Selected Color
            KeyboardColorPreview(selectedTheme: selectedTheme)

            // Color Selection Grid
            VStack(spacing: 16) {
                Text("Choose Color:")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(KeyboardColorTheme.availableThemes, id: \.id) { theme in
                        ColorThemeButton(
                            theme: theme,
                            isSelected: selectedTheme.id == theme.id
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTheme = theme
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            // Save Button
            VStack(spacing: 12) {
                Button(action: saveColorSelection) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)

                        Text("save_color_selection")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTheme.color)
                            .shadow(color: selectedTheme.color.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                }
                .disabled(selectedTheme.id == colorManager.selectedTheme.id)
                .opacity(selectedTheme.id == colorManager.selectedTheme.id ? 0.6 : 1.0)
                .padding(.horizontal, 20)

                // Success Message
                if showSavedMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.islamicGreen)

                        Text("color_saved_successfully")
                            .font(.subheadline)
                            .foregroundColor(.islamicGreen)
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .padding(.vertical, 20)
        .environmentLanguage(languageManager.currentLanguage)
        .onAppear {
            selectedTheme = colorManager.selectedTheme
        }
    }

    private func saveColorSelection() {
        withAnimation(.easeInOut(duration: 0.3)) {
            colorManager.setTheme(selectedTheme)
            showSavedMessage = true
        }

        // Скрываем сообщение через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSavedMessage = false
            }
        }

        // Принудительная синхронизация с клавиатурой
        NotificationCenter.default.post(name: NSNotification.Name("KeyboardColorChanged"), object: selectedTheme.id)
    }
}

struct KeyboardColorPreview: View {
    @StateObject private var languageManager = LanguageManager.shared
    let selectedTheme: KeyboardColorTheme

    let samplePhrases = ["Bismillah", "Alhamdulillah", "SubhanAllah", "InshaAllah"]

    private var previewButtonColor: Color {
        return selectedTheme.color
    }

    private var previewTextColor: Color {
        if selectedTheme.id == "pure_white" || selectedTheme.id == "golden_amber" || selectedTheme.id == "warm_orange" {
            return .black
        } else {
            return .white
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Preview:")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            // Mini Keyboard Preview
            VStack(spacing: 8) {
                // Keyboard Header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "book.quran")
                            .font(.caption2)
                            .foregroundColor(previewButtonColor)
                        Text("Muslim AI Keyboard")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // Language Toggle (Mini)
                    HStack(spacing: 4) {
                        Text("Eng")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(previewTextColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(previewButtonColor)
                            )

                        Text("Рус")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                // Sample Phrase Buttons
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 2), spacing: 6) {
                    ForEach(samplePhrases, id: \.self) { phrase in
                        Text(phrase)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(previewTextColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(previewButtonColor)
                                    .shadow(color: previewButtonColor.opacity(0.3), radius: 2, x: 0, y: 1)
                            )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.8))
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .frame(maxWidth: 280)
        }
    }
}

struct ColorThemeButton: View {
    let theme: KeyboardColorTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Color Circle
                ZStack {
                    Circle()
                        .fill(theme.color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                        )
                        .shadow(color: theme.color.opacity(0.4), radius: isSelected ? 8 : 4, x: 0, y: 2)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(theme.id == "pure_white" ? .black : .white)
                    }
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                
                // Color Name
                Text(theme.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 32)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        KeyboardColorPickerView()
    }
}

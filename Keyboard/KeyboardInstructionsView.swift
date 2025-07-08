//
//  KeyboardInstructionsView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct KeyboardInstructionsView: View {
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "keyboard.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.islamicGreen)
                                .padding(.top, 20)
                            
                            Text("keyboard_title")
                                .amiriQuranBoldFont(size: 28)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("keyboard_subtitle")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        
                        // Setup Steps
                        VStack(spacing: 16) {
                            InstructionStep(number: "1", text: "keyboard_step1", icon: "hand.tap.fill")
                            InstructionStep(number: "2", text: "keyboard_step2", icon: "gear.circle.fill")
                            InstructionStep(number: "3", text: "keyboard_step3", icon: "plus.square.fill")
                            InstructionStep(number: "4", text: "keyboard_step4", icon: "checkmark.square.fill")
                            InstructionStep(number: "5", text: "keyboard_step5", icon: "lock.open.fill")
                        }
                        .padding(.horizontal, 24)
                        
                        // Add Keyboard Button
                        Button(action: {
                            openKeyboardSettings()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "keyboard.fill")
                                    .font(.title2)
                                Text("button_add_keyboard")
                                    .font(.title3)
                                    .fontWeight(.semibold)
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
                        .padding(.horizontal, 24)
                        
                        // Keyboard Color Customization Section
                        KeyboardColorPickerView()
                            .padding(.vertical, 10)

                        // Keyboard Preview Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("keyboard_preview_title")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("keyboard_preview_description")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(nil)

                            // Chat Interface Mockup
                            ChatInterfaceMockup()
                        }
                        .padding(24)
                        .islamicCardStyle()
                        .padding(.horizontal, 24)

                        // How to Use Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("keyboard_how_to_use")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("keyboard_usage_description")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(nil)

                            // Visual Guide
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.title)
                                    .foregroundColor(.islamicGreen)

                                Image(systemName: "arrow.right")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.6))

                                Text("Muslim AI")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.islamicGreen)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.islamicGreen.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .islamicCardStyle()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("tab_keyboard")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .environmentLanguage(languageManager.currentLanguage)
    }
    
    private func openKeyboardSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct ChatInterfaceMockup: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedPhrase: String? = nil
    @State private var chatText = ""

    var body: some View {
        VStack(spacing: 16) {
            // Chat Messages Area
            VStack(spacing: 12) {
                // Sample chat messages
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Hello! How are you?")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(18)
                        Text("12:34 PM")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: 250, alignment: .trailing)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(selectedPhrase ?? "Assalamu Alaikum")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.islamicGreen)
                                .foregroundColor(.white)
                                .cornerRadius(18)

                            if selectedPhrase != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.islamicGreen)
                                    .font(.caption)
                            }
                        }
                        Text("12:35 PM")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: 250, alignment: .leading)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)

            // Text Input Area
            HStack(spacing: 12) {
                HStack {
                    TextField("Type a message...", text: $chatText)
                        .foregroundColor(.white)
                        .font(.body)

                    Button(action: {}) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.islamicGreen)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(25)
            }

            // Keyboard Mockup
            KeyboardMockup(selectedPhrase: $selectedPhrase)
        }
    }
}

struct KeyboardMockup: View {
    @Binding var selectedPhrase: String?
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var colorManager = KeyboardColorManager.shared

    let phrases = [
        "Assalamu Alaikum", "Bismillah", "Alhamdulillah",
        "SubhanAllah", "InshaAllah", "MashaAllah"
    ]

    // Симулируем доступные языки (в реальности это будет из настроек)
    private var availableLanguages: [AppLanguage] {
        // Для демонстрации показываем оба языка, но в реальности это будет из UserDefaults
        return [.english, .russian]
    }

    private var shouldShowLanguageToggle: Bool {
        return availableLanguages.count > 1
    }

    var body: some View {
        VStack(spacing: 0) {
            // Keyboard Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "book.quran")
                        .font(.caption)
                        .foregroundColor(colorManager.keyboardButtonColor)
                    Text("Muslim AI Keyboard")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // Language Toggle - только если доступно несколько языков
                if shouldShowLanguageToggle {
                    HStack(spacing: 4) {
                        if availableLanguages.contains(.english) {
                            Button("Eng") {
                                // Language toggle action
                            }
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(languageManager.currentLanguage == .english ? colorManager.keyboardButtonTextColor : .white.opacity(0.7))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(languageManager.currentLanguage == .english ? colorManager.keyboardButtonColor : Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }

                        if availableLanguages.contains(.russian) {
                            Button("Rus") {
                                // Language toggle action
                            }
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(languageManager.currentLanguage == .russian ? colorManager.keyboardButtonTextColor : .white.opacity(0.7))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(languageManager.currentLanguage == .russian ? colorManager.keyboardButtonColor : Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.3))

            // Islamic Phrases Grid
            VStack(spacing: 8) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(phrases, id: \.self) { phrase in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPhrase = phrase
                            }
                        }) {
                            Text(phrase)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedPhrase == phrase ? colorManager.keyboardButtonTextColor : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedPhrase == phrase ? colorManager.selectedButtonColor : colorManager.keyboardButtonColor.opacity(0.8))
                                        .shadow(color: selectedPhrase == phrase ? colorManager.keyboardButtonColor.opacity(0.4) : colorManager.keyboardButtonColor.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                                .scaleEffect(selectedPhrase == phrase ? 1.05 : 1.0)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // Instruction text
                Text("👆 Tap any phrase to insert it")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Standard Keyboard Rows (simplified)
            VStack(spacing: 6) {
                // First row
                HStack(spacing: 3) {
                    ForEach(["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], id: \.self) { key in
                        Button(key) {}
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 26, height: 30)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(6)
                    }
                }

                // Second row
                HStack(spacing: 3) {
                    ForEach(["A", "S", "D", "F", "G", "H", "J", "K", "L"], id: \.self) { key in
                        Button(key) {}
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 26, height: 30)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(6)
                    }
                }

                // Third row with space
                HStack(spacing: 3) {
                    Button("⇧") {}
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 35, height: 30)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(6)

                    ForEach(["Z", "X", "C", "V", "B", "N", "M"], id: \.self) { key in
                        Button(key) {}
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 26, height: 30)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(6)
                    }

                    Button("⌫") {}
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 35, height: 30)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(6)
                }

                // Bottom row
                HStack(spacing: 3) {
                    Button("123") {}
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 30)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(6)

                    Button("🌐") {}
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(6)

                    Button("space") {}
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(6)

                    Button("return") {}
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 30)
                        .background(Color.islamicGreen.opacity(0.8))
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.9), Color.black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}

struct InstructionStep: View {
    let number: String
    let text: LocalizedStringKey
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            // Step Number
            ZStack {
                Circle()
                    .fill(Color.islamicGreen)
                    .frame(width: 40, height: 40)

                Text(number)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }

            // Step Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundColor(.islamicGreen)

                    Text(text)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(nil)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    KeyboardInstructionsView()
}

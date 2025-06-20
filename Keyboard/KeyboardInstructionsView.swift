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
                            Image(systemName: "keyboard")
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
                            InstructionStep(number: "1", text: "keyboard_step1", icon: "hand.tap")
                            InstructionStep(number: "2", text: "keyboard_step2", icon: "gearshape")
                            InstructionStep(number: "3", text: "keyboard_step3", icon: "plus.circle")
                            InstructionStep(number: "4", text: "keyboard_step4", icon: "checkmark.circle")
                            InstructionStep(number: "5", text: "keyboard_step5", icon: "lock.open")
                        }
                        .padding(.horizontal, 24)
                        
                        // Add Keyboard Button
                        Button(action: {
                            openKeyboardSettings()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "keyboard")
                                    .font(.title2)
                                Text("button_add_keyboard")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.black)
                            .islamicButtonStyle()
                            .background(Color.islamicGreen)
                        }
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
            .navigationTitle("tab_keyboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .environmentLanguage(languageManager.currentLanguage)
    }
    
    private func openKeyboardSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
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

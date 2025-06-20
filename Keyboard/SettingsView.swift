//
//  SettingsView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showLanguageSelection = false
    @State private var showKeyboardLanguageSelection = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Language Section
                        SettingsSection(title: "settings_language") {
                            SettingsRow(
                                icon: "globe",
                                title: "settings_change_language",
                                subtitle: languageManager.currentLanguage.displayName,
                                action: {
                                    showLanguageSelection = true
                                }
                            )
                        }

                        // Keyboard Section
                        SettingsSection(title: "keyboard_settings") {
                            SettingsRow(
                                icon: "keyboard",
                                title: "keyboard_languages_title",
                                subtitle: "Configure keyboard languages",
                                action: {
                                    showKeyboardLanguageSelection = true
                                }
                            )
                        }
                        


                        // About Section
                        SettingsSection(title: "settings_about") {
                            SettingsRow(
                                icon: "info.circle",
                                title: "settings_version",
                                subtitle: "1.0.0"
                            )
                            
                            SettingsRow(
                                icon: "questionmark.circle",
                                title: "settings_support",
                                action: {
                                    // Open support
                                }
                            )
                            
                            SettingsRow(
                                icon: "doc.text",
                                title: "settings_privacy",
                                action: {
                                    // Open privacy policy
                                }
                            )
                            
                            SettingsRow(
                                icon: "doc.plaintext",
                                title: "settings_terms",
                                action: {
                                    // Open terms of service
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("settings_title")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .environmentLanguage(languageManager.currentLanguage)
        .sheet(isPresented: $showLanguageSelection) {
            LanguageSelectionView {
                showLanguageSelection = false
            }
        }
        .sheet(isPresented: $showKeyboardLanguageSelection) {
            KeyboardLanguageSelectionView()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: LocalizedStringKey
    let content: Content
    
    init(title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 16)
            
            VStack(spacing: 1) {
                content
            }
            .islamicCardStyle()
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: LocalizedStringKey, subtitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.islamicGreen)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

#Preview {
    SettingsView()
}

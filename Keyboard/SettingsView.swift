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
    @State private var showSupport = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsConditions = false
    
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
                                icon: "keyboard.fill",
                                title: "keyboard_languages_title",
                                subtitle: "Configure keyboard languages",
                                action: {
                                    showKeyboardLanguageSelection = true
                                }
                            )

                            SettingsDivider()

                            SettingsLanguageSelectionRow(
                                icon: "textformat.abc",
                                title: "keyboard_arabic_text_title",
                                subtitle: "keyboard_arabic_text_subtitle",
                                selectedLanguage: languageManager.arabicLanguagePreference,
                                onLanguageSelected: { language in
                                    languageManager.setArabicLanguagePreference(language)
                                }
                            )

                            SettingsDivider()

                            SettingsDuaLanguageSelectionRow(
                                icon: "book.closed",
                                title: "keyboard_arabic_dua_text_title",
                                subtitle: "keyboard_arabic_dua_text_subtitle",
                                selectedLanguage: languageManager.arabicDuaLanguagePreference,
                                onLanguageSelected: { language in
                                    languageManager.setArabicDuaLanguagePreference(language)
                                }
                            )

                            SettingsDivider()

                            SettingsArabicDisplayModeRow(
                                icon: "textformat",
                                title: "arabic_display_mode_title",
                                subtitle: "arabic_display_mode_subtitle",
                                selectedMode: languageManager.arabicDisplayMode,
                                onModeSelected: { mode in
                                    languageManager.setArabicDisplayMode(mode)
                                }
                            )
                        }

                        // Content Selection Section
                        SettingsSection(title: "content_settings") {
                            NavigationLink(destination: IslamicPhrasesView()) {
                                SettingsRow(
                                    icon: "book.fill",
                                    title: "select_phrases_title",
                                    subtitle: "Choose phrases for keyboard"
                                )
                            }

                            SettingsDivider()

                            NavigationLink(destination: DuaSelectionView()) {
                                SettingsRow(
                                    icon: "hands.and.sparkles.fill",
                                    title: "select_duas_title",
                                    subtitle: "Choose duas for keyboard"
                                )
                            }
                        }

                        // Appearance Section
                        SettingsSection(title: "appearance_settings") {
                            NavigationLink(destination: KeyboardColorPickerView()) {
                                SettingsRow(
                                    icon: "paintbrush.fill",
                                    title: "keyboard_color_title",
                                    subtitle: "Customize keyboard colors"
                                )
                            }
                        }



                        // About Section
                        SettingsSection(title: "settings_about") {
                            SettingsRow(
                                icon: "info.square.fill",
                                title: "settings_version",
                                subtitle: "1.0.0"
                            )

                            SettingsDivider()

                            SettingsRow(
                                icon: "questionmark.square.fill",
                                title: "settings_support",
                                action: {
                                    showSupport = true
                                }
                            )

                            SettingsDivider()

                            SettingsRow(
                                icon: "doc.fill",
                                title: "settings_privacy",
                                action: {
                                    showPrivacyPolicy = true
                                }
                            )

                            SettingsDivider()

                            SettingsRow(
                                icon: "doc.text.fill",
                                title: "settings_terms",
                                action: {
                                    showTermsConditions = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("settings_title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .environmentLanguage(languageManager.currentLanguage)
        .sheet(isPresented: $showLanguageSelection) {
            LanguageSelectionView {
                showLanguageSelection = false
            }
        }
        .sheet(isPresented: $showKeyboardLanguageSelection) {
            KeyboardLanguageSelectionView()
        }
        .sheet(isPresented: $showSupport) {
            SupportView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsConditions) {
            TermsConditionsView()
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
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content
            }
            .islamicCardStyle()
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                // Icon with fixed frame
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.islamicGreen)
                    .frame(width: 32, height: 32)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer()

                // Arrow indicator
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.islamicGreen)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let isOn: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Icon with fixed frame
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.islamicGreen)
                .frame(width: 32, height: 32)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            // Toggle switch
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { newValue in
                    onToggle(newValue)
                }
            ))
            .toggleStyle(SwitchToggleStyle(tint: .islamicGreen))
            .scaleEffect(0.8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.clear)
    }
}

struct SettingsLanguageSelectionRow: View {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let selectedLanguage: AppLanguage?
    let onLanguageSelected: (AppLanguage?) -> Void

    @State private var showingLanguageSelection = false

    private var displayText: String {
        if let selectedLanguage = selectedLanguage {
            return selectedLanguage.displayName
        } else {
            return NSLocalizedString("arabic_disabled", comment: "")
        }
    }

    var body: some View {
        Button(action: {
            showingLanguageSelection = true
        }) {
            HStack(spacing: 16) {
                // Icon with fixed frame
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.islamicGreen)
                    .frame(width: 32, height: 32)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                // Selected value and arrow
                VStack(alignment: .trailing, spacing: 4) {
                    Text(displayText)
                        .font(.caption)
                        .foregroundColor(.islamicGreen)
                        .fontWeight(.medium)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.islamicGreen)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingLanguageSelection) {
            ArabicLanguageSelectionView(
                selectedLanguage: selectedLanguage,
                onLanguageSelected: onLanguageSelected
            )
        }
    }
}

struct SettingsDuaLanguageSelectionRow: View {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let selectedLanguage: AppLanguage?
    let onLanguageSelected: (AppLanguage?) -> Void

    @State private var showingLanguageSelection = false

    private var displayText: String {
        if let selectedLanguage = selectedLanguage {
            return selectedLanguage.displayName
        } else {
            return NSLocalizedString("arabic_disabled", comment: "")
        }
    }

    var body: some View {
        Button(action: {
            showingLanguageSelection = true
        }) {
            HStack(spacing: 16) {
                // Icon with fixed frame
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.islamicGreen)
                    .frame(width: 32, height: 32)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                // Selected value and arrow
                VStack(alignment: .trailing, spacing: 4) {
                    Text(displayText)
                        .font(.caption)
                        .foregroundColor(.islamicGreen)
                        .fontWeight(.medium)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.islamicGreen)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingLanguageSelection) {
            ArabicDuaLanguageSelectionView(
                selectedLanguage: selectedLanguage,
                onLanguageSelected: onLanguageSelected
            )
        }
    }
}

struct SettingsArabicDisplayModeRow: View {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let selectedMode: ArabicDisplayMode
    let onModeSelected: (ArabicDisplayMode) -> Void

    @State private var showingModeSelection = false

    private var displayText: String {
        return selectedMode.displayName
    }

    var body: some View {
        Button(action: {
            showingModeSelection = true
        }) {
            HStack(spacing: 16) {
                // Icon with fixed frame
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.islamicGreen)
                    .frame(width: 32, height: 32)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                // Selected value and arrow
                VStack(alignment: .trailing, spacing: 4) {
                    Text(displayText)
                        .font(.caption)
                        .foregroundColor(.islamicGreen)
                        .fontWeight(.medium)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.islamicGreen)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingModeSelection) {
            ArabicDisplayModeSelectionView(
                selectedMode: selectedMode,
                onModeSelected: onModeSelected
            )
        }
    }
}

// MARK: - Helper Views
struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 0.5)
            .padding(.leading, 48) // Align with content after icon
    }
}

#Preview {
    SettingsView()
}

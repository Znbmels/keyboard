//
//  SupportView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct SupportView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header Section (text only)
                        VStack(spacing: 20) {
                            // App Title
                            Text("Muslim AI Keyboard")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            // Subtitle
                            Text("support_subtitle")
                                .amiriQuranFont(size: 18)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 30)
                        

                        
                        // Social Media Section
                        SupportSection(title: "support_social_title") {
                            VStack(spacing: 12) {
                                SupportActionRow(
                                    icon: "camera.fill",
                                    title: "support_instagram",
                                    subtitle: "@muslimkeyboard.app",
                                    action: openInstagram
                                )
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                SupportActionRow(
                                    icon: "bird.fill",
                                    title: "support_twitter",
                                    subtitle: "@mail_zero56272",
                                    action: openTwitter
                                )

                                Divider()
                                    .background(Color.white.opacity(0.1))

                                SupportActionRow(
                                    icon: "paperplane.fill",
                                    title: "support_telegram",
                                    subtitle: "@muslimaikeyboard",
                                    action: openTelegram
                                )

                                Divider()
                                    .background(Color.white.opacity(0.1))

                                SupportActionRow(
                                    icon: "envelope.fill",
                                    title: "support_email",
                                    subtitle: "znbmels@gmail.com",
                                    action: openEmail
                                )
                            }
                        }

                        // Troubleshooting Section
                        SupportSection(title: "troubleshooting_title") {
                            VStack(spacing: 16) {
                                TroubleshootingItem(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "keyboard_not_visible_title",
                                    description: "keyboard_not_visible_description",
                                    steps: [
                                        "troubleshooting_step1",
                                        "troubleshooting_step2",
                                        "troubleshooting_step3",
                                        "troubleshooting_step4"
                                    ]
                                )

                                TroubleshootingItem(
                                    icon: "arrow.clockwise.circle.fill",
                                    title: "keyboard_not_working_title",
                                    description: "keyboard_not_working_description",
                                    steps: [
                                        "troubleshooting_restart_step1",
                                        "troubleshooting_restart_step2",
                                        "troubleshooting_restart_step3"
                                    ]
                                )
                            }
                        }

                        // Heart Message Section
                        VStack(spacing: 16) {
                            Text("support_heart_title")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 12) {
                                Text("💚")
                                    .font(.system(size: 30))
                                
                                Text("support_heart_message")
                                    .amiriQuranFont(size: 16)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 24)
                            .padding(.horizontal, 20)
                            .islamicCardStyle()
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("support_title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.islamicGreen)
                }
            }
        }
        .environmentLanguage(languageManager.currentLanguage)
    }
    
    // MARK: - Actions
    
    private func openInstagram() {
        let instagramURL = "https://www.instagram.com/muslimkeyboard.app/"
        if let url = URL(string: instagramURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTwitter() {
        let twitterURL = "https://x.com/mail_zero56272"
        if let url = URL(string: twitterURL) {
            UIApplication.shared.open(url)
        }
    }

    private func openTelegram() {
        let telegramURL = "https://t.me/muslimaikeyboard"
        if let url = URL(string: telegramURL) {
            UIApplication.shared.open(url)
        }
    }

    private func openEmail() {
        let emailURL = "mailto:znbmels@gmail.com"
        if let url = URL(string: emailURL) {
            UIApplication.shared.open(url)
        }
    }
}

struct SupportSection<Content: View>: View {
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
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                content
            }
            .islamicCardStyle()
        }
    }
}

struct SupportActionRow: View {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.islamicGreen)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
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
                
                Image(systemName: "arrow.up.right.square.fill")
                    .font(.caption)
                    .foregroundColor(.islamicGreen)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Troubleshooting Component
struct TroubleshootingItem: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let steps: [LocalizedStringKey]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.islamicGreen)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.islamicGreen)
                            .frame(width: 20, alignment: .leading)

                        Text(step)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 36)
        }
        .padding(16)
        .islamicCardStyle()
    }
}

#Preview {
    SupportView()
}

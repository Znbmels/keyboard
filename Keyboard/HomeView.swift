//
//  HomeView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var phrasesManager = IslamicPhrasesManager()
    @State private var refreshID = UUID()

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header Section
                        VStack(spacing: 16) {
                            // App Icon/Logo placeholder
                            Image(systemName: "book.quran")
                                .font(.system(size: 60))
                                .foregroundColor(.islamicGreen)
                                .padding(.top, 20)
                            
                            Text("home_welcome_title")
                                .amiriQuranBoldFont(size: 28)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("home_welcome_subtitle")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        
                        // Description Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("home_description")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(nil)
                        }
                        .padding(24)
                        .islamicCardStyle()
                        .padding(.horizontal, 24)
                        
                        // Features Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("home_features_title")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 16) {
                                FeatureRow(icon: "brain.head.profile", text: "home_feature1")
                                FeatureRow(icon: "book.closed", text: "home_feature2")
                                FeatureRow(icon: "globe", text: "home_feature3")
                                FeatureRow(icon: "hand.tap", text: "home_feature4")
                            }
                        }
                        .padding(24)
                        .islamicCardStyle()
                        .padding(.horizontal, 24)
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            // Islamic Phrases Button - Main Feature
                            NavigationLink(destination: IslamicPhrasesView()) {
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "book.quran")
                                            .font(.title)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("islamic_phrases_title")
                                                .font(.title2)
                                                .fontWeight(.bold)

                                            HStack(spacing: 4) {
                                                Text("\(phrasesManager.selectedCount)/\(phrasesManager.phrases.count)")
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                Text("selected")
                                                    .font(.caption)
                                            }
                                            .foregroundColor(.white.opacity(0.8))
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.title3)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .foregroundColor(.white)

                                    Text("islamic_phrases_subtitle")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.islamicGreen)
                                        .shadow(color: .islamicGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                                )
                            }



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
                                .background(Color.white)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("tab_home")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .environmentLanguage(languageManager.currentLanguage)
        .id(refreshID)
        .onChange(of: languageManager.currentLanguage) { _ in
            // Refresh the view when language changes
            refreshID = UUID()
        }
    }
    
    private func openKeyboardSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.islamicGreen)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}

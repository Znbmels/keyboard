//
//  HomeView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var refreshID = UUID()

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Main Content - Centered
                    VStack(spacing: 40) {
                        // Welcome Title
                        Text("home_welcome_title")
                            .amiriQuranBoldFont(size: 32)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        // Main Buttons
                        VStack(spacing: 20) {
                            // Islamic Phrases Button
                            NavigationLink(destination: IslamicPhrasesView()) {
                                HStack(spacing: 16) {
                                    Image(systemName: "book.fill")
                                        .font(.title)
                                        .foregroundColor(.white)

                                    Text("islamic_phrases_title")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.title3)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(Color.islamicGreen)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            }

                            // Short Duas Button
                            NavigationLink(destination: DuaListView()) {
                                HStack(spacing: 16) {
                                    Image(systemName: "hands.and.sparkles.fill")
                                        .font(.title)
                                        .foregroundColor(.black)

                                    Text("short_duas_title")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.title3)
                                        .foregroundColor(.black.opacity(0.8))
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, 32)
                    }

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .environmentLanguage(languageManager.currentLanguage)
        .id(refreshID)
        .onChange(of: languageManager.currentLanguage) {
            // Refresh the view when language changes
            refreshID = UUID()
        }
    }
}

#Preview {
    HomeView()
}

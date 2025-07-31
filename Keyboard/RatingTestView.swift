//
//  RatingTestView.swift
//  Keyboard
//
//  Created by Zainab on 18.07.2025.
//

import SwiftUI

struct RatingTestView: View {
    @StateObject private var ratingManager = AppRatingManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showTestPopup = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Text("🌟 Rating System Test")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Test the new rating popup")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Test buttons
                    VStack(spacing: 16) {
                        Button("Show Rating Popup") {
                            showTestPopup = true
                        }
                        .buttonStyle(TestButtonStyle())
                        
                        Button("Trigger Rating (3 Stickers)") {
                            // Simulate 3 successful sticker generations
                            for _ in 0..<3 {
                                ratingManager.markSuccessfulStickerGeneration()
                            }
                        }
                        .buttonStyle(TestButtonStyle(color: .orange))
                        
                        Button("Trigger Rating (6 Phrases)") {
                            // Simulate 6 phrase usages
                            for _ in 0..<6 {
                                ratingManager.markPhraseUsage()
                            }
                        }
                        .buttonStyle(TestButtonStyle(color: .blue))
                        
                        Button("Test App Store Link") {
                            // Test direct App Store link
                            let appStoreURL = "https://apps.apple.com/kz/app/muslim-ai-keyboard/id6748057376?action=write-review"
                            if let url = URL(string: appStoreURL) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .buttonStyle(TestButtonStyle(color: .purple))

                        Button("Reset Rating Data") {
                            ratingManager.resetRatingData()
                        }
                        .buttonStyle(TestButtonStyle(color: .red))
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.top, 50)
            }
            .navigationTitle("Rating Test")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay(
            // Test popup overlay
            Group {
                if showTestPopup {
                    RatingPopupView(
                        isPresented: $showTestPopup,
                        onRatePressed: {
                            print("✅ Test: Rate button pressed")
                            showTestPopup = false
                        },
                        onNotNowPressed: {
                            print("⏸️ Test: Not now button pressed")
                            showTestPopup = false
                        },
                        onNeverPressed: {
                            print("❌ Test: Never ask button pressed")
                            showTestPopup = false
                        }
                    )
                    .zIndex(1000)
                }
            }
        )
        .overlay(
            // Real rating popup overlay
            Group {
                if ratingManager.showRatingPopup {
                    RatingPopupView(
                        isPresented: $ratingManager.showRatingPopup,
                        onRatePressed: {
                            ratingManager.handleRateButtonPressed()
                        },
                        onNotNowPressed: {
                            ratingManager.handleNotNowPressed()
                        },
                        onNeverPressed: {
                            ratingManager.handleNeverAskPressed()
                        }
                    )
                    .zIndex(1001)
                }
            }
        )
        .environmentLanguage(languageManager.currentLanguage)
    }
}

struct TestButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = .islamicGreen) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#if DEBUG
#Preview {
    RatingTestView()
}
#endif

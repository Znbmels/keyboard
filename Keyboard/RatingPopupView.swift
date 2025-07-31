//
//  RatingPopupView.swift
//  Keyboard
//
//  Created by Zainab on 18.07.2025.
//

import SwiftUI
import StoreKit

struct RatingPopupView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var ratingManager = AppRatingManager.shared
    @Binding var isPresented: Bool
    
    let onRatePressed: () -> Void
    let onNotNowPressed: () -> Void
    let onNeverPressed: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onNotNowPressed()
                }
            
            // Main popup card
            VStack(spacing: 0) {
                // Header with stars
                VStack(spacing: 16) {
                    // Star decoration
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundColor(.islamicGreen)
                                .scaleEffect(index == 2 ? 1.2 : 1.0) // Middle star slightly larger
                        }
                    }
                    .padding(.top, 24)
                    
                    // Title
                    Text("rating_popup_title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                
                // Message
                VStack(spacing: 16) {
                    Text("rating_popup_message")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // Islamic decoration
                    HStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.caption)
                            .foregroundColor(.islamicGreen.opacity(0.7))
                        
                        Rectangle()
                            .fill(Color.islamicGreen.opacity(0.3))
                            .frame(height: 1)
                        
                        Image(systemName: "hands.and.sparkles.fill")
                            .font(.caption)
                            .foregroundColor(.islamicGreen.opacity(0.7))
                        
                        Rectangle()
                            .fill(Color.islamicGreen.opacity(0.3))
                            .frame(height: 1)
                        
                        Image(systemName: "moon.stars.fill")
                            .font(.caption)
                            .foregroundColor(.islamicGreen.opacity(0.7))
                    }
                    .padding(.horizontal, 40)
                }
                
                // Buttons
                VStack(spacing: 12) {
                    // Rate button
                    Button(action: {
                        onRatePressed()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Text("rating_popup_rate_button")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.islamicGreen, .islamicGreen.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .islamicGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(RatingButtonStyle())
                    
                    // Secondary buttons row
                    HStack(spacing: 12) {
                        // Not now button
                        Button(action: {
                            onNotNowPressed()
                        }) {
                            Text("rating_popup_not_now_button")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .buttonStyle(RatingButtonStyle())
                        
                        // Never ask button
                        Button(action: {
                            onNeverPressed()
                        }) {
                            Text("rating_popup_never_button")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.clear)
                                .cornerRadius(10)
                        }
                        .buttonStyle(RatingButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.islamicGreen.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)
            .scaleEffect(isPresented ? 1.0 : 0.8)
            .opacity(isPresented ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
        }
        .environment(\.layoutDirection, .leftToRight)
        .environmentLanguage(languageManager.currentLanguage)
    }
}

// Custom button style for rating popup
struct RatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Preview
#Preview {
    RatingPopupView(
        isPresented: .constant(true),
        onRatePressed: { print("Rate pressed") },
        onNotNowPressed: { print("Not now pressed") },
        onNeverPressed: { print("Never pressed") }
    )
}

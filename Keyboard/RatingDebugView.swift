//
//  RatingDebugView.swift
//  Keyboard
//
//  Created by Zainab on 18.07.2025.
//

import SwiftUI

struct RatingDebugView: View {
    @StateObject private var ratingManager = AppRatingManager.shared
    @State private var debugInfo: [String: Any] = [:]
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 10) {
                            Text("🌟 Rating System Debug")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("For testing purposes only")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        // Current Stats
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Statistics")
                                .font(.headline)
                                .foregroundColor(.islamicGreen)
                            
                            ForEach(Array(debugInfo.keys.sorted()), id: \.self) { key in
                                HStack {
                                    Text(key.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.body)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(debugInfo[key] ?? "N/A")")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.islamicGreen)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Test Actions
                        VStack(spacing: 16) {
                            Text("Test Actions")
                                .font(.headline)
                                .foregroundColor(.islamicGreen)
                            
                            Button("Mark Onboarding Completed") {
                                ratingManager.markOnboardingCompleted()
                                refreshDebugInfo()
                                showAlert(message: "Onboarding marked as completed")
                            }
                            .buttonStyle(DebugButtonStyle())
                            
                            Button("Mark Sticker Generation") {
                                ratingManager.markSuccessfulStickerGeneration()
                                refreshDebugInfo()
                                showAlert(message: "Sticker generation marked")
                            }
                            .buttonStyle(DebugButtonStyle())
                            
                            Button("Mark Phrase Usage") {
                                ratingManager.markPhraseUsage()
                                refreshDebugInfo()
                                showAlert(message: "Phrase usage marked")
                            }
                            .buttonStyle(DebugButtonStyle())
                            
                            Button("Request Rating Manually") {
                                Task {
                                    await ratingManager.requestRatingManually()
                                    refreshDebugInfo()
                                    showAlert(message: "Rating request sent")
                                }
                            }
                            .buttonStyle(DebugButtonStyle(color: .orange))
                            
                            Button("Reset All Data") {
                                ratingManager.resetRatingData()
                                refreshDebugInfo()
                                showAlert(message: "All rating data reset")
                            }
                            .buttonStyle(DebugButtonStyle(color: .red))
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Rating Debug")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                refreshDebugInfo()
            }
            .alert("Debug Action", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func refreshDebugInfo() {
        debugInfo = ratingManager.getDebugInfo()
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct DebugButtonStyle: ButtonStyle {
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
            .padding(.vertical, 12)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#if DEBUG
#Preview {
    RatingDebugView()
}
#endif

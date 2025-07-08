//
//  PhraseDetailView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct PhraseDetailView: View {
    let phrase: IslamicPhrase
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Arabic Text
                        VStack(spacing: 8) {
                            Text(phrase.arabic)
                                .font(.custom("AmiriQuran", size: 48))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Transliteration
                        VStack(spacing: 8) {
                            Text("transliteration")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .textCase(.uppercase)
                            
                            Text(phrase.transliteration)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding(.horizontal)
                        
                        // Meaning
                        VStack(spacing: 12) {
                            Text("meaning")
                                .font(.headline)
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                            
                            Text(phrase.meaning)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding(.horizontal)
                        
                        // Usage Recommendations
                        VStack(spacing: 12) {
                            Text("when_to_use")
                                .font(.headline)
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                            
                            Text(phrase.usage)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
                
                ToolbarItem(placement: .principal) {
                    Text(phrase.transliteration)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct PhraseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PhraseDetailView(phrase: IslamicPhrase(
            key: "bismillah",
            arabic: "بسم الله",
            englishTransliteration: "Bismillah",
            russianTransliteration: "Бисмиллях",
            englishMeaning: "In the name of Allah",
            russianMeaning: "Во имя Аллаха",
            englishUsage: "Before starting any task, eating, or sending a message",
            russianUsage: "Перед началом дела, еды, сообщения",
            kazakhTransliteration: "Бисмиллях",
            arabicTransliteration: "بسم الله",
            kazakhMeaning: "Алланың атымен",
            arabicMeaning: "بسم الله",
            kazakhUsage: "Кез келген істі бастамас бұрын, тамақ ішер алдында",
            arabicUsage: "قبل بدء أي مهمة أو تناول الطعام"
        ))
    }
}


//
//  IslamicPhrasesView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct IslamicPhrasesView: View {
    @StateObject private var phrasesManager = IslamicPhrasesManager()
    @StateObject private var languageManager = LanguageManager.shared
    @State private var searchText = ""
    @State private var refreshID = UUID()

    var filteredPhrases: [IslamicPhrase] {
        if searchText.isEmpty {
            return phrasesManager.phrases
        }

        let lowercasedSearch = searchText.lowercased()
        return phrasesManager.phrases.filter { phrase in
            let arabicMatch = phrase.arabic.contains(searchText)
            let transliterationMatch = phrase.transliteration.lowercased().contains(lowercasedSearch)
            let localizedMatch = phrase.localizedText.lowercased().contains(lowercasedSearch)

            return arabicMatch || transliterationMatch || localizedMatch
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with selection controls
                    VStack(spacing: 16) {
                        Text("islamic_phrases_subtitle")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)


                        
                        // Selection Stats and Controls
                        HStack {
                            Text("\(phrasesManager.selectedCount)/\(phrasesManager.phrases.count)")
                                .font(.caption)
                                .foregroundColor(.islamicGreen)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.islamicGreen.opacity(0.2))
                                .cornerRadius(12)
                            
                            Spacer()
                            
                            Button("select_all") {
                                phrasesManager.selectAll()
                            }
                            .font(.caption)
                            .foregroundColor(.islamicGreen)
                            
                            Text("•")
                                .foregroundColor(.white.opacity(0.4))
                            
                            Button("deselect_all") {
                                phrasesManager.deselectAll()
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 10)

                    // Phrases List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredPhrases) { phrase in
                                IslamicPhraseRow(
                                    phrase: phrase,
                                    onToggle: {
                                        phrasesManager.togglePhrase(phrase)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                        .id(refreshID)
                    }
                }
            }
            .navigationTitle("islamic_phrases_title")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .environmentLanguage(languageManager.currentLanguage)
        .onChange(of: languageManager.currentLanguage) { _ in
            // Refresh the view when language changes
            refreshID = UUID()
        }
    }
}

struct IslamicPhraseRow: View {
    let phrase: IslamicPhrase
    let onToggle: () -> Void

    private var backgroundShape: some View {
        let fillColor = phrase.isSelected ? Color.islamicGreen.opacity(0.1) : Color.white.opacity(0.05)
        let strokeColor = phrase.isSelected ? Color.islamicGreen.opacity(0.3) : Color.white.opacity(0.1)

        return RoundedRectangle(cornerRadius: 16)
            .fill(fillColor)
            .stroke(strokeColor, lineWidth: 1)
    }

    private var scaleValue: CGFloat {
        phrase.isSelected ? 1.02 : 1.0
    }

    private var scaleAnimation: Animation {
        .easeInOut(duration: 0.2)
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Selection Checkbox
                ZStack {
                    let strokeColor = phrase.isSelected ? Color.islamicGreen : Color.white.opacity(0.3)

                    RoundedRectangle(cornerRadius: 6)
                        .stroke(strokeColor, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if phrase.isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.islamicGreen)
                    }
                }
                
                // Phrase Content
                VStack(alignment: .leading, spacing: 8) {
                    // Arabic Text
                    HStack {
                        Text(phrase.arabic)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.islamicGreen)
                        
                        Spacer()
                    }
                    
                    // Transliteration
                    HStack {
                        Text(phrase.transliteration)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    // Localized Translation
                    HStack {
                        Text(phrase.localizedText)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                backgroundShape
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(scaleValue)
        .animation(scaleAnimation, value: phrase.isSelected)
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))

            TextField("Search phrases...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    IslamicPhrasesView()
}

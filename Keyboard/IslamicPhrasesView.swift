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
                    // Selection Controls - Compact
                    HStack {
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

                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Search phrases...")
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("islamic_phrases_title")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("islamic_phrases_subtitle")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .environmentLanguage(languageManager.currentLanguage)
        .onChange(of: languageManager.currentLanguage) {
            // Refresh the view when language changes
            refreshID = UUID()
        }
    }
}

struct IslamicPhraseRow: View {
    let phrase: IslamicPhrase
    let onToggle: () -> Void
    @State private var showingDetail = false

    private var backgroundShape: some View {
        let fillColor = phrase.isSelected ? Color.islamicGreen.opacity(0.15) : Color.white.opacity(0.05)
        let strokeColor = phrase.isSelected ? Color.islamicGreen : Color.white.opacity(0.1)

        return RoundedRectangle(cornerRadius: 12)
            .fill(fillColor)
            .stroke(strokeColor, lineWidth: phrase.isSelected ? 2 : 1)
    }

    private var scaleValue: CGFloat {
        phrase.isSelected ? 1.02 : 1.0
    }

    private var scaleAnimation: Animation {
        .easeInOut(duration: 0.2)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Selection Checkbox
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(phrase.isSelected ? Color.islamicGreen : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(phrase.isSelected ? Color.islamicGreen : Color.white.opacity(0.3), lineWidth: 2)
                        )

                    if phrase.isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }

            // Phrase Content - Clickable for details
            Button(action: { showingDetail = true }) {
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
            }
            .buttonStyle(PlainButtonStyle())

            // Info button
            Button(action: { showingDetail = true }) {
                Image(systemName: "info.square.fill")
                    .font(.title3)
                    .foregroundColor(.islamicGreen)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(backgroundShape)
        .scaleEffect(scaleValue)
        .animation(scaleAnimation, value: phrase.isSelected)
        .sheet(isPresented: $showingDetail) {
            PhraseDetailView(phrase: phrase)
        }
    }
}



#Preview {
    IslamicPhrasesView()
}

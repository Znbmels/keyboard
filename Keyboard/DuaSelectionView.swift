//
//  DuaSelectionView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct DuaSelectionView: View {
    @StateObject private var duaManager = DuaManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var refreshID = UUID()
    
    var filteredDuas: [Dua] {
        if searchText.isEmpty {
            return duaManager.duas
        }
        
        let lowercasedSearch = searchText.lowercased()
        return duaManager.duas.filter { dua in
            let titleMatch = dua.title.lowercased().contains(lowercasedSearch)
            let arabicMatch = dua.arabicText.contains(searchText)
            let translationMatch = dua.translation.lowercased().contains(lowercasedSearch)
            
            return titleMatch || arabicMatch || translationMatch
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Text("select_duas_subtitle")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        // Selection Counter
                        Text(selectedCount)
                            .font(.caption)
                            .foregroundColor(.islamicGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.islamicGreen.opacity(0.2))
                            )
                    }
                    .padding(.bottom, 20)
                    
                    // Search Bar
                    SearchBar(text: $searchText, placeholder: NSLocalizedString("search_duas", comment: ""))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 10)
                    
                    // Duas List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredDuas) { dua in
                                DuaSelectionRow(dua: dua)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
                    VStack(spacing: 4) {
                        Text("select_duas_title")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("select_duas_subtitle")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .environmentLanguage(languageManager.currentLanguage)
        .onChange(of: languageManager.currentLanguage) {
            refreshID = UUID()
        }
    }
    
    private var selectedCount: String {
        let count = duaManager.selectedDuas.count
        let currentLanguage = languageManager.currentLanguage
        
        switch currentLanguage {
        case .russian:
            return "Выбрано: \(count)"
        case .english, .french, .german, .chinese, .hindi, .kyrgyz, .uzbek, .korean, .urdu, .spanish, .italian:
            return "Selected: \(count)"
        case .kazakh:
            return "Таңдалған: \(count)"
        case .arabic:
            return "المحدد: \(count)"
        }
    }
}

struct DuaSelectionRow: View {
    let dua: Dua
    @StateObject private var duaManager = DuaManager.shared
    @State private var showingDetail = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Selection Checkbox
            Button(action: {
                duaManager.toggleDuaSelection(dua)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(dua.isSelected ? Color.islamicGreen : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(dua.isSelected ? Color.islamicGreen : Color.white.opacity(0.3), lineWidth: 2)
                        )

                    if dua.isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Dua Info
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.islamicGreen)
                            .frame(width: 32, height: 32)

                        Image(systemName: dua.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    // Title
                    Text(dua.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Spacer()
                }
                
                // Arabic preview
                Text(String(dua.arabicText.prefix(30)) + (dua.arabicText.count > 30 ? "..." : ""))
                    .font(.subheadline)
                    .foregroundColor(.islamicGreen)
                    .lineLimit(1)
                
                // Translation preview
                Text(String(dua.translation.prefix(50)) + (dua.translation.count > 50 ? "..." : ""))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            // Detail Button
            Button(action: {
                showingDetail = true
            }) {
                Image(systemName: "info.square.fill")
                    .font(.title3)
                    .foregroundColor(.islamicGreen)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(dua.isSelected ? Color.islamicGreen.opacity(0.15) : Color.white.opacity(0.05))
                .stroke(dua.isSelected ? Color.islamicGreen : Color.white.opacity(0.1), lineWidth: dua.isSelected ? 2 : 1)
        )
        .sheet(isPresented: $showingDetail) {
            DuaDetailView(dua: dua)
        }
    }
}

struct DuaSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DuaSelectionView()
    }
}

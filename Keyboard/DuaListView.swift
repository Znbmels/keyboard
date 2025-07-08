//  DuaListView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct DuaListView: View {
    @StateObject private var duaManager = DuaManager.shared
    @StateObject private var languageManager = LanguageManager.shared
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
                
                VStack(spacing: 20) { // Увеличил spacing для лучшего разделения
                    // Header (центрированный заголовок)
                    Text("short_duas_subtitle")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity) // Занимает всю ширину для центрирования
                        .padding(.horizontal, 24) // Сохраняем отступы для читаемости
                    
                    // Search Bar (центрированный под заголовком)
                    SearchBar(text: $searchText, placeholder: NSLocalizedString("search_duas", comment: ""))
                        .frame(maxWidth: 300) // Ограничиваем ширину для центрирования
                        .padding(.horizontal)
                    
                    // Duas Grid (центрированный под SearchBar)
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                            ForEach(filteredDuas) { dua in
                                DuaCard(dua: dua)
                            }
                        }
                        .padding(.horizontal, 24) // Сохраняем отступы для симметрии
                        .padding(.bottom, 100)
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // Центрируем сетку
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Центрируем весь VStack
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("short_duas_title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .environmentLanguage(languageManager.currentLanguage)
        .onChange(of: languageManager.currentLanguage) {
            refreshID = UUID()
        }
    }
}

struct DuaCard: View {
    let dua: Dua
    @State private var showingDetail = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(spacing: 12) {
                // Icon with background
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.islamicGreen)
                        .frame(width: 40, height: 40)

                    Image(systemName: dua.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Title
                Text(dua.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Arabic preview (first few words)
                Text(String(dua.arabicText.prefix(15)) + (dua.arabicText.count > 15 ? "..." : ""))
                    .font(.caption2)
                    .foregroundColor(.islamicGreen)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.03)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(Color.islamicGreen.opacity(0.3), lineWidth: 1)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {
            // Long press action
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .sheet(isPresented: $showingDetail) {
            DuaDetailView(dua: dua)
        }
    }
}

struct DuaListView_Previews: PreviewProvider {
    static var previews: some View {
        DuaListView()
    }
}

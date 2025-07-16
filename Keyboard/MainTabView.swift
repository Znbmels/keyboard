//
//  MainTabView.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("tab_home")
                }
                .tag(0)

            // Stickers Tab
            StickerGeneratorView()
                .tabItem {
                    Image(systemName: "face.smiling.fill")
                    Text("tab_stickers")
                }
                .tag(1)

            // Keyboard Tab when is select
            KeyboardInstructionsView()
                .tabItem {
                    Image(systemName: "keyboard.fill")
                    Text("tab_keyboard")
                }
                .tag(2)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gear.circle.fill")
                    Text("tab_settings")
                }
                .tag(3)
        }
        .environment(\.layoutDirection, .leftToRight)
        .accentColor(.islamicGreen)
        .preferredColorScheme(.dark)
        .environmentLanguage(languageManager.currentLanguage)
    }
}

#Preview {
    MainTabView()
}

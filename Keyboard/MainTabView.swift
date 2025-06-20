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

            // Keyboard Tab
            KeyboardInstructionsView()
                .tabItem {
                    Image(systemName: "keyboard")
                    Text("tab_keyboard")
                }
                .tag(1)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("tab_settings")
                }
                .tag(2)
        }
        .accentColor(.islamicGreen)
        .preferredColorScheme(.dark)
        .environmentLanguage(languageManager.currentLanguage)
    }
}

#Preview {
    MainTabView()
}

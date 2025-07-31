//
//  KeyboardApp.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

@main
struct KeyboardApp: App {

    init() {
        // Инициализируем систему рейтинга при запуске приложения
        Task { @MainActor in
            _ = AppRatingManager.shared
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onAppear {
                    // Синхронизируем данные из клавиатуры при появлении приложения
                    Task {
                        await AppRatingManager.shared.syncPhraseUsageFromKeyboard()
                    }
                }
        }
    }
}

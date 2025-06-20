//
//  AppCoordinator.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

enum AppState {
    case onboarding
    case languageSelection
    case main
}

class AppCoordinator: ObservableObject {
    @Published var currentState: AppState = .onboarding
    @StateObject private var languageManager = LanguageManager.shared
    
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "onboarding_completed"
    private let languageSelectedKey = "language_selected"
    
    init() {
        print("🚀 AppCoordinator: Initializing...")
        // Сбрасываем состояние при каждом запуске приложения
        resetOnboardingState()
        determineInitialState()
        print("🎯 AppCoordinator: Initial state set to \(currentState)")
    }

    private func resetOnboardingState() {
        // Сбрасываем флаги онбординга при каждом запуске
        print("🔄 AppCoordinator: Resetting onboarding state...")
        userDefaults.set(false, forKey: onboardingCompletedKey)
        userDefaults.set(false, forKey: languageSelectedKey)
        print("✅ AppCoordinator: Onboarding state reset")
    }
    
    private func determineInitialState() {
        // ВСЕГДА запускаем онбординг при каждом билдинге приложения
        currentState = .onboarding

        // Комментируем старую логику для возможного восстановления:
        /*
        let onboardingCompleted = userDefaults.bool(forKey: onboardingCompletedKey)
        let languageSelected = userDefaults.bool(forKey: languageSelectedKey)

        if !onboardingCompleted {
            currentState = .onboarding
        } else if !languageSelected {
            currentState = .languageSelection
        } else {
            currentState = .main
        }
        */
    }
    
    func completeOnboarding() {
        print("✅ AppCoordinator: Onboarding completed, moving to language selection")
        userDefaults.set(true, forKey: onboardingCompletedKey)
        currentState = .languageSelection
    }

    func completeLanguageSelection() {
        print("✅ AppCoordinator: Language selection completed, moving to main")
        userDefaults.set(true, forKey: languageSelectedKey)
        currentState = .main
    }
    
    func resetToOnboarding() {
        userDefaults.set(false, forKey: onboardingCompletedKey)
        userDefaults.set(false, forKey: languageSelectedKey)
        currentState = .onboarding
    }
}

struct AppCoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        Group {
            switch coordinator.currentState {
            case .onboarding:
                OnboardingView(onComplete: {
                    coordinator.completeOnboarding()
                })
                .onAppear {
                    print("📱 AppCoordinatorView: Showing onboarding")
                }

            case .languageSelection:
                LanguageSelectionView {
                    coordinator.completeLanguageSelection()
                }
                .onAppear {
                    print("📱 AppCoordinatorView: Showing language selection")
                }

            case .main:
                MainTabView()
                .onAppear {
                    print("📱 AppCoordinatorView: Showing main tab view")
                }
            }
        }
        .environmentLanguage(languageManager.currentLanguage)
        .animation(.easeInOut(duration: 0.5), value: coordinator.currentState)
    }
}

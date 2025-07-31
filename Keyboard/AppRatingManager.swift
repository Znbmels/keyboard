//
//  AppRatingManager.swift
//  Keyboard
//
//  Created by Zainab on 18.07.2025.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class AppRatingManager: ObservableObject {
    static let shared = AppRatingManager()

    // MARK: - Published Properties
    @Published var showRatingPopup = false

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let hasCompletedOnboarding = "has_completed_onboarding"
        static let successfulStickerGenerations = "successful_sticker_generations"
        static let successfulPhraseUsages = "successful_phrase_usages"
        static let lastRatingRequestDate = "last_rating_request_date"
        static let hasRatedApp = "has_rated_app"
        static let ratingRequestCount = "rating_request_count"
        static let appLaunchCount = "app_launch_count"
        static let firstLaunchDate = "first_launch_date"
        static let neverAskForRating = "never_ask_for_rating"
    }
    
    // MARK: - Configuration
    private let minDaysBetweenRequests: Int = 30 // Минимум 30 дней между запросами
    private let maxRequestsPerYear: Int = 3 // Максимум 3 запроса в год
    private let minAppUsageDays: Int = 3 // Минимум 3 дня использования приложения
    
    // MARK: - Trigger Thresholds
    private let stickerGenerationThreshold: Int = 3 // После 3 успешных генераций
    private let phraseUsageThreshold: Int = 10 // После 10 использований фраз
    private let appLaunchThreshold: Int = 5 // После 5 запусков приложения
    
    private init() {
        setupFirstLaunchIfNeeded()
    }
    
    // MARK: - Setup
    private func setupFirstLaunchIfNeeded() {
        if UserDefaults.standard.object(forKey: Keys.firstLaunchDate) == nil {
            UserDefaults.standard.set(Date(), forKey: Keys.firstLaunchDate)
            print("📱 First app launch recorded")
        }
        
        // Увеличиваем счетчик запусков
        let currentCount = UserDefaults.standard.integer(forKey: Keys.appLaunchCount)
        UserDefaults.standard.set(currentCount + 1, forKey: Keys.appLaunchCount)
        print("📱 App launch count: \(currentCount + 1)")
    }
    
    // MARK: - Event Tracking
    
    /// Отмечает завершение онбординга
    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: Keys.hasCompletedOnboarding)
        print("✅ Onboarding completed")
        
        // Проверяем, можно ли показать запрос рейтинга
        Task {
            await checkAndRequestRatingIfAppropriate(trigger: .onboardingCompleted)
        }
    }
    
    /// Отмечает успешную генерацию стикера
    func markSuccessfulStickerGeneration() {
        let currentCount = UserDefaults.standard.integer(forKey: Keys.successfulStickerGenerations)
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: Keys.successfulStickerGenerations)
        print("🎨 Successful sticker generations: \(newCount)")
        
        // Проверяем пороговое значение
        if newCount >= stickerGenerationThreshold {
            Task {
                await checkAndRequestRatingIfAppropriate(trigger: .stickerGeneration(count: newCount))
            }
        }
    }
    
    /// Отмечает использование фразы/дуа
    func markPhraseUsage() {
        // Синхронизируем данные из клавиатуры
        syncPhraseUsageFromKeyboard()

        let currentCount = UserDefaults.standard.integer(forKey: Keys.successfulPhraseUsages)
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: Keys.successfulPhraseUsages)
        print("📝 Phrase usages: \(newCount)")

        // Проверяем пороговое значение
        if newCount >= phraseUsageThreshold {
            Task {
                await checkAndRequestRatingIfAppropriate(trigger: .phraseUsage(count: newCount))
            }
        }
    }

    /// Синхронизирует данные об использовании фраз из клавиатуры
    func syncPhraseUsageFromKeyboard() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") else { return }

        let keyboardUsageCount = sharedDefaults.integer(forKey: "phrase_usage_count")
        let currentAppCount = UserDefaults.standard.integer(forKey: Keys.successfulPhraseUsages)

        if keyboardUsageCount > 0 {
            let totalCount = currentAppCount + keyboardUsageCount
            UserDefaults.standard.set(totalCount, forKey: Keys.successfulPhraseUsages)

            // Очищаем счетчик в клавиатуре после синхронизации
            sharedDefaults.set(0, forKey: "phrase_usage_count")
            sharedDefaults.synchronize()

            print("🔄 Synced \(keyboardUsageCount) phrase usages from keyboard. Total: \(totalCount)")
        }
    }
    
    /// Отмечает, что пользователь оценил приложение
    func markAppAsRated() {
        UserDefaults.standard.set(true, forKey: Keys.hasRatedApp)
        UserDefaults.standard.set(Date(), forKey: Keys.lastRatingRequestDate)
        print("⭐ App marked as rated")
    }
    
    // MARK: - Rating Request Logic
    
    private enum RatingTrigger {
        case onboardingCompleted
        case stickerGeneration(count: Int)
        case phraseUsage(count: Int)
        case appLaunches(count: Int)
        
        var description: String {
            switch self {
            case .onboardingCompleted:
                return "onboarding completed"
            case .stickerGeneration(let count):
                return "\(count) sticker generations"
            case .phraseUsage(let count):
                return "\(count) phrase usages"
            case .appLaunches(let count):
                return "\(count) app launches"
            }
        }
    }
    
    private func checkAndRequestRatingIfAppropriate(trigger: RatingTrigger) async {
        print("🔍 Checking rating request eligibility for trigger: \(trigger.description)")
        
        // Проверяем все условия
        guard shouldRequestRating() else {
            print("❌ Rating request not appropriate at this time")
            return
        }
        
        print("✅ All conditions met, requesting rating")
        await requestRating()
    }
    
    private func shouldRequestRating() -> Bool {
        // 1. Проверяем, не оценил ли уже пользователь приложение
        if UserDefaults.standard.bool(forKey: Keys.hasRatedApp) {
            print("❌ User has already rated the app")
            return false
        }

        // 2. Проверяем, не выбрал ли пользователь "никогда не спрашивать"
        if UserDefaults.standard.bool(forKey: Keys.neverAskForRating) {
            print("❌ User chose never to be asked for rating")
            return false
        }

        // 3. Проверяем, завершен ли онбординг
        guard UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding) else {
            print("❌ Onboarding not completed yet")
            return false
        }
        
        // 3. Устанавливаем дату первого запуска если её нет
        if UserDefaults.standard.object(forKey: Keys.firstLaunchDate) == nil {
            UserDefaults.standard.set(Date(), forKey: Keys.firstLaunchDate)
        }
        
        // 4. Проверяем время с последнего запроса
        if let lastRequestDate = UserDefaults.standard.object(forKey: Keys.lastRatingRequestDate) as? Date {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequestDate, to: Date()).day ?? 0
            guard daysSinceLastRequest >= minDaysBetweenRequests else {
                print("❌ Too soon since last request: \(daysSinceLastRequest) days (need \(minDaysBetweenRequests))")
                return false
            }
        }
        
        // 5. Проверяем максимальное количество запросов в год
        let requestCount = UserDefaults.standard.integer(forKey: Keys.ratingRequestCount)
        guard requestCount < maxRequestsPerYear else {
            print("❌ Maximum requests per year reached: \(requestCount)")
            return false
        }
        
        // 6. Проверяем количество запусков приложения (показываем после 3-го запуска)
        let launchCount = UserDefaults.standard.integer(forKey: Keys.appLaunchCount)
        guard launchCount >= 3 else {
            print("❌ Not enough app launches: \(launchCount)/3")
            return false
        }
        
        print("✅ All rating request conditions satisfied")
        return true
    }
    
    private func requestRating() async {
        // Обновляем статистику запросов
        let currentRequestCount = UserDefaults.standard.integer(forKey: Keys.ratingRequestCount)
        UserDefaults.standard.set(currentRequestCount + 1, forKey: Keys.ratingRequestCount)
        UserDefaults.standard.set(Date(), forKey: Keys.lastRatingRequestDate)

        print("⭐ Requesting app rating (request #\(currentRequestCount + 1))")

        // Показываем наше всплывающее окно
        showRatingPopup = true
    }
    
    // MARK: - Manual Rating Request

    /// Ручной запрос рейтинга (например, из настроек)
    func requestRatingManually() async {
        print("⭐ Manual rating request")
        // Для ручного запроса сразу открываем App Store
        openAppStoreForRating()
    }

    // MARK: - Popup Actions

    /// Пользователь нажал "Оценить в App Store"
    func handleRateButtonPressed() {
        print("⭐ User pressed Rate button")
        showRatingPopup = false
        markAppAsRated()

        // Открываем App Store для оценки
        openAppStoreForRating()
    }

    /// Пользователь нажал "Не сейчас"
    func handleNotNowPressed() {
        print("⭐ User pressed Not Now")
        showRatingPopup = false
        // Не делаем ничего особенного, просто закрываем окно
        // Пользователь может получить запрос снова позже
    }

    /// Пользователь нажал "Больше не спрашивать"
    func handleNeverAskPressed() {
        print("⭐ User pressed Never Ask Again")
        showRatingPopup = false
        UserDefaults.standard.set(true, forKey: Keys.neverAskForRating)
        UserDefaults.standard.set(Date(), forKey: Keys.lastRatingRequestDate)
    }

    /// Открывает App Store для оценки приложения
    private func openAppStoreForRating() {
        // Прямая ссылка на страницу оценки приложения Muslim AI Keyboard
        let appStoreURL = "https://apps.apple.com/kz/app/muslim-ai-keyboard/id6748057376?action=write-review"

        if let url = URL(string: appStoreURL) {
            Task { @MainActor in
                if await UIApplication.shared.canOpenURL(url) {
                    await UIApplication.shared.open(url)
                    print("✅ Opening App Store for rating: \(appStoreURL)")
                } else {
                    print("❌ Cannot open App Store URL: \(appStoreURL)")
                    // Fallback - открываем основную страницу приложения
                    let fallbackURL = "https://apps.apple.com/kz/app/muslim-ai-keyboard/id6748057376"
                    if let fallbackUrl = URL(string: fallbackURL) {
                        await UIApplication.shared.open(fallbackUrl)
                    }
                }
            }
        }
    }
    
    // MARK: - Debug Information
    
    func getDebugInfo() -> [String: Any] {
        return [
            "hasCompletedOnboarding": UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding),
            "stickerGenerations": UserDefaults.standard.integer(forKey: Keys.successfulStickerGenerations),
            "phraseUsages": UserDefaults.standard.integer(forKey: Keys.successfulPhraseUsages),
            "appLaunches": UserDefaults.standard.integer(forKey: Keys.appLaunchCount),
            "hasRatedApp": UserDefaults.standard.bool(forKey: Keys.hasRatedApp),
            "requestCount": UserDefaults.standard.integer(forKey: Keys.ratingRequestCount),
            "lastRequestDate": UserDefaults.standard.object(forKey: Keys.lastRatingRequestDate) as? Date ?? "Never",
            "firstLaunchDate": UserDefaults.standard.object(forKey: Keys.firstLaunchDate) as? Date ?? "Unknown",
            "daysSinceFirstLaunch": {
                guard let firstLaunch = UserDefaults.standard.object(forKey: Keys.firstLaunchDate) as? Date else { return 0 }
                return Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
            }()
        ]
    }
    
    // MARK: - Reset (for testing)
    
    func resetRatingData() {
        let keys = [Keys.hasCompletedOnboarding, Keys.successfulStickerGenerations, Keys.successfulPhraseUsages,
                   Keys.lastRatingRequestDate, Keys.hasRatedApp, Keys.ratingRequestCount, Keys.appLaunchCount, Keys.firstLaunchDate]
        
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        setupFirstLaunchIfNeeded()
        print("🔄 Rating data reset")
    }
}

//
//  AppVersionManager.swift
//  Keyboard
//
//  Created by Zainab on 21.07.2025.
//

import SwiftUI
import Foundation

@MainActor
class AppVersionManager: ObservableObject {
    static let shared = AppVersionManager()
    
    // MARK: - Published Properties
    @Published var showUpdateAlert = false
    @Published var latestVersion: String = ""
    @Published var updateMessage: String = ""
    @Published var isUpdateRequired = false
    
    // MARK: - Private Properties
    private let currentVersion = "1.0.4"
    private let appStoreURL = "https://apps.apple.com/kz/app/muslim-ai-keyboard/id6748057376"
    private let appID = "6748057376"
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let lastVersionCheck = "last_version_check"
        static let dismissedVersion = "dismissed_update_version"
        static let updateCheckInterval = "update_check_interval"
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Проверяет наличие обновлений при запуске приложения
    func checkForUpdatesOnLaunch() async {
        // Проверяем не чаще одного раза в день
        let lastCheck = UserDefaults.standard.object(forKey: Keys.lastVersionCheck) as? Date ?? Date.distantPast
        let daysSinceLastCheck = Calendar.current.dateComponents([.day], from: lastCheck, to: Date()).day ?? 0
        
        guard daysSinceLastCheck >= 1 else {
            print("🔄 Version check skipped - checked recently")
            return
        }
        
        await checkForUpdates()
    }
    
    /// Принудительная проверка обновлений
    func checkForUpdates() async {
        print("🔍 Checking for app updates...")
        
        do {
            let appStoreVersion = try await fetchLatestVersionFromAppStore()
            UserDefaults.standard.set(Date(), forKey: Keys.lastVersionCheck)
            
            if isNewerVersion(appStoreVersion, than: currentVersion) {
                print("✅ New version available: \(appStoreVersion) (current: \(currentVersion))")
                
                // Проверяем, не отклонял ли пользователь эту версию
                let dismissedVersion = UserDefaults.standard.string(forKey: Keys.dismissedVersion) ?? ""
                if dismissedVersion != appStoreVersion {
                    await showUpdateNotification(newVersion: appStoreVersion)
                }
            } else {
                print("✅ App is up to date")
            }
        } catch {
            print("❌ Failed to check for updates: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Получает последнюю версию из App Store
    private func fetchLatestVersionFromAppStore() async throws -> String {
        let url = URL(string: "https://itunes.apple.com/lookup?id=\(appID)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let results = json?["results"] as? [[String: Any]]
        let version = results?.first?["version"] as? String
        
        guard let version = version else {
            throw NSError(domain: "AppVersionManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not parse version"])
        }
        
        return version
    }
    
    /// Сравнивает версии
    private func isNewerVersion(_ version1: String, than version2: String) -> Bool {
        return version1.compare(version2, options: .numeric) == .orderedDescending
    }
    
    /// Показывает уведомление об обновлении
    private func showUpdateNotification(newVersion: String) async {
        latestVersion = newVersion
        updateMessage = getLocalizedUpdateMessage()
        showUpdateAlert = true
    }
    
    /// Возвращает локализованное сообщение об обновлении
    private func getLocalizedUpdateMessage() -> String {
        return "update_available_message".localized
    }
    
    // MARK: - User Actions
    
    /// Пользователь нажал "Обновить"
    func handleUpdatePressed() {
        showUpdateAlert = false
        openAppStore()
    }
    
    /// Пользователь нажал "Позже"
    func handleLaterPressed() {
        showUpdateAlert = false
        // Не сохраняем отклонение, чтобы показать снова через день
    }
    
    /// Пользователь нажал "Пропустить эту версию"
    func handleSkipVersionPressed() {
        showUpdateAlert = false
        UserDefaults.standard.set(latestVersion, forKey: Keys.dismissedVersion)
        print("🚫 User skipped version: \(latestVersion)")
    }
    
    /// Открывает App Store для обновления
    private func openAppStore() {
        guard let url = URL(string: appStoreURL) else { return }
        
        Task { @MainActor in
            if await UIApplication.shared.canOpenURL(url) {
                await UIApplication.shared.open(url)
                print("✅ Opening App Store for update")
            } else {
                print("❌ Cannot open App Store URL")
            }
        }
    }
}

// MARK: - Update Alert View
struct UpdateAlertView: View {
    @ObservedObject private var versionManager = AppVersionManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    versionManager.handleLaterPressed()
                }
            
            // Main alert card
            VStack(spacing: 0) {
                // Header with Islamic decoration
                VStack(spacing: 16) {
                    // Islamic star decoration
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .font(.title3)
                                .foregroundColor(.islamicGreen)
                                .scaleEffect(index == 2 ? 1.2 : 1.0)
                        }
                    }
                    .padding(.top, 24)
                    
                    // Title
                    Text("update_available_title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                
                // Message
                VStack(spacing: 16) {
                    Text("update_available_message")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // Version info
                    Text("update_version_info \(versionManager.latestVersion)")
                        .font(.caption)
                        .foregroundColor(.islamicGreen)
                        .padding(.horizontal, 24)
                    
                    // Islamic decoration
                    HStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.caption)
                            .foregroundColor(.islamicGreen.opacity(0.7))
                        
                        Rectangle()
                            .fill(Color.islamicGreen.opacity(0.3))
                            .frame(height: 1)
                        
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.caption)
                            .foregroundColor(.islamicGreen.opacity(0.7))
                        
                        Rectangle()
                            .fill(Color.islamicGreen.opacity(0.3))
                            .frame(height: 1)
                        
                        Image(systemName: "moon.stars.fill")
                            .font(.caption)
                            .foregroundColor(.islamicGreen.opacity(0.7))
                    }
                    .padding(.horizontal, 40)
                }
                
                // Buttons
                VStack(spacing: 12) {
                    // Update button
                    Button(action: {
                        versionManager.handleUpdatePressed()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Text("update_now_button")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.islamicGreen, .islamicGreen.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .islamicGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // Later button
                    Button(action: {
                        versionManager.handleLaterPressed()
                    }) {
                        Text("update_later_button")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Skip version button
                    Button(action: {
                        versionManager.handleSkipVersionPressed()
                    }) {
                        Text("update_skip_version_button")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .padding(.top, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.islamicGreen.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)
            .scaleEffect(isPresented ? 1.0 : 0.8)
            .opacity(isPresented ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
        }
        .environment(\.layoutDirection, .leftToRight)
        .environmentLanguage(languageManager.currentLanguage)
    }
}

#Preview {
    UpdateAlertView(isPresented: .constant(true))
}

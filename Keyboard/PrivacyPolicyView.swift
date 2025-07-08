//
//  PrivacyPolicyView.swift
//  Keyboard
//
//  Created by Zainab on 02.07.2025.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        introductionSection
                        privacySections
                        governingLawSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.islamicGreen)
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .environmentLanguage(languageManager.currentLanguage)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text(languageManager.currentLanguage == .russian ? "Политика конфиденциальности" : "Privacy Policy")
                .font(languageManager.currentLanguage == .russian ? .title2 : .largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(languageManager.currentLanguage == .russian ? "Дата вступления в силу: 1 июля 2025 г." : "Effective Date: July 1, 2025")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.bottom, 20)
    }
    
    private var introductionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(getIntroductionText())
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .islamicCardStyle()
    }
    
    private var privacySections: some View {
        VStack(spacing: 16) {
            PrivacySection(
                number: "1",
                title: getSectionTitle(1),
                content: getSectionContent(1),
                isRussian: languageManager.currentLanguage == .russian
            )
            
            PrivacySection(
                number: "2",
                title: getSectionTitle(2),
                content: getSectionContent(2),
                isRussian: languageManager.currentLanguage == .russian
            )

            PrivacySection(
                number: "3",
                title: getSectionTitle(3),
                content: getSectionContent(3),
                isRussian: languageManager.currentLanguage == .russian
            )

            PrivacySection(
                number: "4",
                title: getSectionTitle(4),
                content: getSectionContent(4),
                isRussian: languageManager.currentLanguage == .russian
            )
            
            PrivacySection(
                number: "5",
                title: getSectionTitle(5),
                content: getSectionContent(5),
                isRussian: languageManager.currentLanguage == .russian
            )
            
            PrivacySection(
                number: "6",
                title: getSectionTitle(6),
                content: getSectionContent(6),
                isRussian: languageManager.currentLanguage == .russian
            )
            
            PrivacySection(
                number: "7",
                title: getSectionTitle(7),
                content: getSectionContent(7),
                isRussian: languageManager.currentLanguage == .russian
            )
        }
    }
    
    private var governingLawSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(languageManager.currentLanguage == .russian ? "Применимое право" : "Governing Law")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.islamicGreen)
            
            Text(languageManager.currentLanguage == .russian ? 
                "Данная Политика конфиденциальности должна толковаться в соответствии с применимыми законами в регионе пользователя или международными стандартами конфиденциальности." :
                "This Privacy Policy shall be interpreted in accordance with applicable laws in the user's region or international privacy standards.")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .islamicCardStyle()
    }
    
    // MARK: - Helper Methods
    
    private func getIntroductionText() -> String {
        if languageManager.currentLanguage == .russian {
            return "Мы уважаем вашу конфиденциальность и стремимся защитить ваши персональные данные. Данная Политика конфиденциальности объясняет, какие данные мы собираем, как мы их используем и каковы ваши права."
        } else {
            return "We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains what data we collect, how we use it, and your rights."
        }
    }
    
    private func getSectionTitle(_ section: Int) -> String {
        if languageManager.currentLanguage == .russian {
            switch section {
            case 1: return "Сбор данных"
            case 2: return "Использование данных"
            case 3: return "Безопасность данных"
            case 4: return "Ваши права"
            case 5: return "Конфиденциальность детей"
            case 6: return "Обновления политики"
            case 7: return "Связаться с нами"
            default: return ""
            }
        } else {
            switch section {
            case 1: return "Data Collection"
            case 2: return "Use of Data"
            case 3: return "Data Security"
            case 4: return "Your Rights"
            case 5: return "Children's Privacy"
            case 6: return "Updates to This Policy"
            case 7: return "Contact Us"
            default: return ""
            }
        }
    }
    
    private func getSectionContent(_ section: Int) -> String {
        if languageManager.currentLanguage == .russian {
            switch section {
            case 1: return "Мы не собираем нажатия клавиш, чаты или личные сообщения.\nМы можем дополнительно собирать анонимную аналитику (например, частоту использования, языковые предпочтения) и локальные настройки (например, темы) для улучшения приложения, которые хранятся локально, если вы не откажетесь."
            case 2: return "Аналитика используется исключительно для улучшения функциональности приложения и не связана с вашей личностью. Никакие данные не продаются и не передаются третьим лицам."
            case 3: return "Локальные данные зашифрованы и недоступны другим приложениям. Мы не используем удаленные серверы для хранения ваших данных."
            case 4: return "Вы можете удалить приложение, чтобы удалить все локальные данные. Вы можете запросить подробности о собранных данных, связавшись с нами. При необходимости у вас есть права в соответствии с GDPR/CCPA на доступ или удаление данных."
            case 5: return "Мы сознательно не собираем данные детей младше 13 лет. Родители могут связаться с нами для запроса удаления данных, если ребенок использовал приложение."
            case 6: return "Мы уведомим вас об изменениях через приложение. Пожалуйста, периодически просматривайте обновления."
            case 7: return "По вопросам конфиденциальности обращайтесь к нам:\nEmail: znbmels@gmail.com (ответ в течение 48 часов)"
            default: return ""
            }
        } else {
            switch section {
            case 1: return "We do not collect keystrokes, chats, or personal messages.\nWe may optionally collect anonymous analytics (e.g., usage frequency, language preferences) and local settings (e.g., themes) to improve the app, stored locally unless you opt out."
            case 2: return "Analytics are used solely to enhance app functionality and are not linked to your identity. No data is sold or shared with third parties."
            case 3: return "Local data is encrypted and not accessible to other apps. We do not use remote servers to store your data."
            case 4: return "You can uninstall the app to delete all local data. You may request details about collected data by contacting us. If applicable, you have rights under GDPR/CCPA to access or delete data."
            case 5: return "We do not knowingly collect data from children under 13. Parents may contact us to request data deletion if a child has used the app."
            case 6: return "We will notify you of changes via the app. Please review updates periodically."
            case 7: return "For privacy questions, contact us:\nEmail: znbmels@gmail.com (response within 48 hours)"
            default: return ""
            }
        }
    }
}

struct PrivacySection: View {
    let number: String
    let title: String
    let content: String
    let isRussian: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(number + ".")
                    .font(isRussian ? .body : .title3)
                    .fontWeight(.bold)
                    .foregroundColor(.islamicGreen)
                
                Text(title)
                    .font(isRussian ? .body : .title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.islamicGreen)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .islamicCardStyle()
    }
}

#Preview {
    PrivacyPolicyView()
}

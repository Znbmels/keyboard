//
//  TermsConditionsView.swift
//  Keyboard
//
//  Created by Zainab on 02.07.2025.
//

import SwiftUI

struct TermsConditionsView: View {
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
                        welcomeSection
                        termsSections
                        governingLawSection
                        blessingSection
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
        .environmentLanguage(languageManager.currentLanguage)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text(languageManager.currentLanguage == .russian ? "Условия использования" : "Terms and Conditions")
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
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(getWelcomeText())
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .islamicCardStyle()
    }
    
    private var termsSections: some View {
        VStack(spacing: 16) {
            TermsSection(
                number: "1",
                title: getTermsSectionTitle(1),
                content: getTermsSectionContent(1),
                isRussian: languageManager.currentLanguage == .russian
            )
            
            TermsSection(
                number: "2",
                title: getTermsSectionTitle(2),
                content: getTermsSectionContent(2),
                isRussian: languageManager.currentLanguage == .russian
            )
            
            TermsSection(
                number: "3",
                title: getTermsSectionTitle(3),
                content: getTermsSectionContent(3),
                isRussian: languageManager.currentLanguage == .russian
            )
            
            TermsSection(
                number: "4",
                title: getTermsSectionTitle(4),
                content: getTermsSectionContent(4),
                isRussian: languageManager.currentLanguage == .russian
            )
            
            TermsSection(
                number: "5",
                title: getTermsSectionTitle(5),
                content: getTermsSectionContent(5),
                isRussian: languageManager.currentLanguage == .russian
            )
            
            TermsSection(
                number: "6",
                title: getTermsSectionTitle(6),
                content: getTermsSectionContent(6),
                isRussian: languageManager.currentLanguage == .russian
            )
            
            TermsSection(
                number: "7",
                title: getTermsSectionTitle(7),
                content: getTermsSectionContent(7),
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
                "Данные Условия регулируются применимыми местными или международными законами, относящимися к местоположению пользователя. Используя Приложение, вы соглашаетесь с условиями, описанными здесь." :
                "These Terms shall be governed by applicable local or international laws, as relevant to the user's location. By using the App, you consent to the terms described here.")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .islamicCardStyle()
    }
    
    private var blessingSection: some View {
        VStack(spacing: 12) {
            Text(languageManager.currentLanguage == .russian ? 
                "Да благословит вас Аллах за использование этого Приложения во благо, ИншаАллах." :
                "May Allah bless you for using this App for good, InshaAllah.")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.islamicGreen)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .islamicCardStyle()
    }
    
    // MARK: - Helper Methods
    
    private func getWelcomeText() -> String {
        if languageManager.currentLanguage == .russian {
            return "Добро пожаловать в Muslim AI Keyboard!\n\nДанные Условия использования (\"Условия\") регулируют ваше использование мобильного приложения Muslim AI Keyboard (\"Приложение\"). Загружая, получая доступ или используя Приложение, вы соглашаетесь соблюдать данные Условия."
        } else {
            return "Welcome to Muslim AI Keyboard!\n\nThese Terms and Conditions (\"Terms\") govern your use of the Muslim AI Keyboard mobile application (\"App\"). By downloading, accessing, or using the App, you agree to be bound by these Terms."
        }
    }
    
    private func getTermsSectionTitle(_ section: Int) -> String {
        if languageManager.currentLanguage == .russian {
            switch section {
            case 1: return "Принятие условий"
            case 2: return "Использование приложения"
            case 3: return "Интеллектуальная собственность"
            case 4: return "Пользовательские данные"
            case 5: return "Обновления"
            case 6: return "Прекращение"
            case 7: return "Контакты"
            default: return ""
            }
        } else {
            switch section {
            case 1: return "Acceptance of Terms"
            case 2: return "Use of the App"
            case 3: return "Intellectual Property"
            case 4: return "User Data"
            case 5: return "Updates"
            case 6: return "Termination"
            case 7: return "Contact"
            default: return ""
            }
        }
    }
    
    private func getTermsSectionContent(_ section: Int) -> String {
        if languageManager.currentLanguage == .russian {
            switch section {
            case 1: return "Вам должно быть не менее 13 лет или у вас должно быть согласие родителей для использования Приложения. Используя Приложение, вы подтверждаете, что прочитали, поняли и согласны с данными Условиями."
            case 2: return "Приложение предназначено для помощи мусульманам в исламском общении. Вы соглашаетесь использовать его только в законных и уважительных целях. Запрещенные действия включают продвижение языка вражды, насилия, дезинформации или материалов, защищенных авторским правом, без разрешения."
            case 3: return "Весь контент, дизайн, логотипы и фразы в Приложении являются собственностью Muslim Keyboard. Пользователям предоставляется неисключительная, непередаваемая лицензия на использование контента Приложения только для личного использования. Коммерческое использование или воспроизведение требует письменного разрешения."
            case 4: return "Мы не собираем персональные данные набора текста. Предпочтения хранятся локально на вашем устройстве, если вы не решите поделиться ими. Мы можем собирать анонимизированные данные об использовании для улучшения Приложения, но они не передаются третьим лицам."
            case 5: return "Мы можем обновлять Приложение и данные Условия в любое время, уведомляя вас через Приложение. Продолжение использования после обновлений означает принятие; в противном случае вы можете удалить Приложение."
            case 6: return "Мы можем прекратить или приостановить доступ к Приложению за нарушения данных Условий, по соображениям безопасности или по нашему усмотрению, что может привести к потере сохраненных предпочтений без предварительного уведомления."
            case 7: return "По вопросам обращайтесь к нам:\nEmail: znbmels@gmail.com (ответ в течение 48 часов)"
            default: return ""
            }
        } else {
            switch section {
            case 1: return "You must be at least 13 years old or have parental consent to use the App. By using the App, you acknowledge that you have read, understood, and agree to these Terms."
            case 2: return "The App is designed to help Muslims communicate Islamically. You agree to use it only for lawful and respectful purposes. Prohibited actions include promoting hate speech, violence, misinformation, or copyrighted material without permission."
            case 3: return "All content, designs, logos, and phrases in the App are the property of Muslim Keyboard. Users are granted a non-exclusive, non-transferable license to use the App's content for personal use only. Commercial use or reproduction requires written permission."
            case 4: return "We do not collect personal typing data. Preferences are stored locally on your device unless you choose to share them. We may collect anonymized usage data to improve the App, but it is not shared with third parties."
            case 5: return "We may update the App and these Terms at any time, notifying you via the App. Continued use after updates signifies acceptance; otherwise, you may uninstall the App."
            case 6: return "We may terminate or suspend access to the App for violations of these Terms, security reasons, or at our discretion, potentially resulting in loss of saved preferences, without prior notice."
            case 7: return "For questions, contact us:\nEmail: znbmels@gmail.com (response within 48 hours)"
            default: return ""
            }
        }
    }
}

struct TermsSection: View {
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
    TermsConditionsView()
}

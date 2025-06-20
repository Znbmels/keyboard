//
//  IslamicPhrase.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import Foundation

struct IslamicPhrase: Identifiable, Codable {
    let id = UUID()
    let key: String
    let arabic: String
    let englishTransliteration: String
    let russianTransliteration: String
    var isSelected: Bool = false

    // Get transliteration based on current language
    var transliteration: String {
        let currentLanguage = LanguageManager.shared.currentLanguage
        switch currentLanguage {
        case .russian:
            return russianTransliteration
        case .english:
            return englishTransliteration
        }
    }

    // Localized display text
    var localizedText: String {
        return NSLocalizedString("phrase_\(key)", comment: "")
    }

    // Display format combining all versions
    var displayText: String {
        return "\(arabic) • \(transliteration) • \(localizedText)"
    }
}

class IslamicPhrasesManager: ObservableObject {
    @Published var phrases: [IslamicPhrase] = []
    
    let userDefaults: UserDefaults
    private let selectedPhrasesKey = "selected_islamic_phrases"

    init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.org.mels.keyboard.muslim") ?? UserDefaults.standard
        loadPhrases()
        loadSelectedPhrases()
    }
    
    private func loadPhrases() {
        phrases = [
            IslamicPhrase(key: "assalamu_alaikum", arabic: "السلام عليكم", englishTransliteration: "Assalamu Alaikum", russianTransliteration: "Ассаламу алейкум"),
            IslamicPhrase(key: "wa_alaikum_assalam", arabic: "وعليكم السلام", englishTransliteration: "Wa Alaikum Assalam", russianTransliteration: "Уа алейкум ассалям"),
            IslamicPhrase(key: "bismillah", arabic: "بسم الله", englishTransliteration: "Bismillah", russianTransliteration: "Бисмиллях"),
            IslamicPhrase(key: "alhamdulillah", arabic: "الحمد لله", englishTransliteration: "Alhamdulillah", russianTransliteration: "Альхамдулиллях"),
            IslamicPhrase(key: "subhanallah", arabic: "سبحان الله", englishTransliteration: "SubhanAllah", russianTransliteration: "Субханаллах"),
            IslamicPhrase(key: "allahu_akbar", arabic: "الله أكبر", englishTransliteration: "Allahu Akbar", russianTransliteration: "Аллаху Акбар"),
            IslamicPhrase(key: "la_ilaha_illallah", arabic: "لا إله إلا الله", englishTransliteration: "La ilaha illallah", russianTransliteration: "Ля иляха илляллах"),
            IslamicPhrase(key: "astaghfirullah", arabic: "أستغفر الله", englishTransliteration: "Astaghfirullah", russianTransliteration: "Астагфируллах"),
            IslamicPhrase(key: "inshallah", arabic: "إن شاء الله", englishTransliteration: "InshaAllah", russianTransliteration: "ИншаАллах"),
            IslamicPhrase(key: "mashallah", arabic: "ما شاء الله", englishTransliteration: "MashaAllah", russianTransliteration: "МашаАллах"),
            IslamicPhrase(key: "jazakallahu_khairan", arabic: "جزاك الله خيراً", englishTransliteration: "JazakAllahu Khairan", russianTransliteration: "Джазакаллаху хайран"),
            IslamicPhrase(key: "barakallahu_feek", arabic: "بارك الله فيك", englishTransliteration: "BarakAllahu Feek", russianTransliteration: "Баракаллаху фик"),
            IslamicPhrase(key: "ameen", arabic: "آمين", englishTransliteration: "Ameen", russianTransliteration: "Аминь"),
            IslamicPhrase(key: "la_hawla", arabic: "لا حول ولا قوة إلا بالله", englishTransliteration: "La hawla wa la quwwata illa billah", russianTransliteration: "Ля хауля уа ля куввата илля биллях"),
            IslamicPhrase(key: "tawakkaltu", arabic: "توكلت على الله", englishTransliteration: "Tawakkaltu 'ala Allah", russianTransliteration: "Таваккальту аля Аллах"),
            IslamicPhrase(key: "rahimahu_allah", arabic: "رحمه الله", englishTransliteration: "Rahimahu Allah", russianTransliteration: "Рахимаху Аллах"),
            IslamicPhrase(key: "fi_amanillah", arabic: "في أمان الله", englishTransliteration: "Fi Amanillah", russianTransliteration: "Фи аманиллях"),
            IslamicPhrase(key: "taqabbal_allah", arabic: "تقبل الله", englishTransliteration: "Taqabbal Allah", russianTransliteration: "ТакяббалАллах"),
            IslamicPhrase(key: "maa_salama", arabic: "مع السلامة", englishTransliteration: "Ma'a Salama", russianTransliteration: "Маа саляма"),
            IslamicPhrase(key: "ya_allah", arabic: "يا الله", englishTransliteration: "Ya Allah", russianTransliteration: "Я Аллах")
        ]
    }
    
    private func loadSelectedPhrases() {
        if let data = userDefaults.data(forKey: selectedPhrasesKey),
           let selectedKeys = try? JSONDecoder().decode([String].self, from: data) {
            for i in 0..<phrases.count {
                phrases[i].isSelected = selectedKeys.contains(phrases[i].key)
            }
        } else {
            // Default: select first 5 phrases
            for i in 0..<min(5, phrases.count) {
                phrases[i].isSelected = true
            }
            saveSelectedPhrases()
        }
    }
    
    func togglePhrase(_ phrase: IslamicPhrase) {
        if let index = phrases.firstIndex(where: { $0.id == phrase.id }) {
            phrases[index].isSelected.toggle()
            saveSelectedPhrases()
        }
    }
    
    func selectAll() {
        for i in 0..<phrases.count {
            phrases[i].isSelected = true
        }
        saveSelectedPhrases()
    }
    
    func deselectAll() {
        for i in 0..<phrases.count {
            phrases[i].isSelected = false
        }
        saveSelectedPhrases()
    }
    
    private func saveSelectedPhrases() {
        let selectedKeys = phrases.filter { $0.isSelected }.map { $0.key }
        print("🔄 IslamicPhrasesManager: Saving \(selectedKeys.count) selected phrases")
        print("   Keys: \(selectedKeys)")

        if let data = try? JSONEncoder().encode(selectedKeys) {
            userDefaults.set(data, forKey: selectedPhrasesKey)
            userDefaults.synchronize()

            // Также сохраняем в обычном ключе для клавиатуры
            userDefaults.set(data, forKey: "keyboard_selected_islamic_phrases")
            userDefaults.synchronize()

            print("✅ IslamicPhrasesManager: Data saved successfully")

            // Отправляем уведомление об изменении
            NotificationCenter.default.post(name: NSNotification.Name("PhrasesUpdated"), object: nil)
        } else {
            print("❌ IslamicPhrasesManager: Failed to encode data")
        }
    }
    
    var selectedPhrases: [IslamicPhrase] {
        return phrases.filter { $0.isSelected }
    }
    
    var selectedCount: Int {
        return phrases.filter { $0.isSelected }.count
    }
}

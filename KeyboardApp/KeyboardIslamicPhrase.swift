//
//  KeyboardIslamicPhrase.swift
//  KeyboardApp
//
//  Created by Zainab on 19.06.2025.
//

import Foundation

struct KeyboardIslamicPhrase {
    let id = UUID()
    let key: String
    let arabic: String
    let englishTransliteration: String
    let russianTransliteration: String
    let englishTranslation: String
    let russianTranslation: String
    
    // Get transliteration based on current language
    func transliteration(for language: KeyboardLanguage) -> String {
        switch language {
        case .russian:
            return russianTransliteration
        case .english:
            return englishTransliteration
        }
    }
    
    // Get translation based on current language
    func translation(for language: KeyboardLanguage) -> String {
        switch language {
        case .russian:
            return russianTranslation
        case .english:
            return englishTranslation
        }
    }
    
    // Get display text for keyboard button
    func displayText(for language: KeyboardLanguage) -> String {
        return transliteration(for: language)
    }
}

class KeyboardPhrasesManager {
    static let shared = KeyboardPhrasesManager()
    
    private let userDefaults: UserDefaults
    private let selectedPhrasesKey = "keyboard_selected_islamic_phrases"
    
    let allPhrases: [KeyboardIslamicPhrase] = [
        KeyboardIslamicPhrase(
            key: "assalamu_alaikum",
            arabic: "السلام عليكم",
            englishTransliteration: "Assalamu Alaikum",
            russianTransliteration: "Ассаламу алейкум",
            englishTranslation: "Peace be upon you",
            russianTranslation: "Мир вам"
        ),
        KeyboardIslamicPhrase(
            key: "wa_alaikum_assalam",
            arabic: "وعليكم السلام",
            englishTransliteration: "Wa Alaikum Assalam",
            russianTransliteration: "Уа алейкум ассалям",
            englishTranslation: "And upon you peace",
            russianTranslation: "И вам мир"
        ),
        KeyboardIslamicPhrase(
            key: "bismillah",
            arabic: "بسم الله",
            englishTransliteration: "Bismillah",
            russianTransliteration: "Бисмиллях",
            englishTranslation: "In the name of Allah",
            russianTranslation: "Во имя Аллаха"
        ),
        KeyboardIslamicPhrase(
            key: "alhamdulillah",
            arabic: "الحمد لله",
            englishTransliteration: "Alhamdulillah",
            russianTransliteration: "Альхамдулиллях",
            englishTranslation: "Praise be to Allah",
            russianTranslation: "Хвала Аллаху"
        ),
        KeyboardIslamicPhrase(
            key: "subhanallah",
            arabic: "سبحان الله",
            englishTransliteration: "SubhanAllah",
            russianTransliteration: "Субханаллах",
            englishTranslation: "Glory be to Allah",
            russianTranslation: "Слава Аллаху"
        ),
        KeyboardIslamicPhrase(
            key: "allahu_akbar",
            arabic: "الله أكبر",
            englishTransliteration: "Allahu Akbar",
            russianTransliteration: "Аллаху Акбар",
            englishTranslation: "Allah is the Greatest",
            russianTranslation: "Аллах велик"
        ),
        KeyboardIslamicPhrase(
            key: "la_ilaha_illallah",
            arabic: "لا إله إلا الله",
            englishTransliteration: "La ilaha illallah",
            russianTransliteration: "Ля иляха илляллах",
            englishTranslation: "There is no god but Allah",
            russianTranslation: "Нет бога кроме Аллаха"
        ),
        KeyboardIslamicPhrase(
            key: "astaghfirullah",
            arabic: "أستغفر الله",
            englishTransliteration: "Astaghfirullah",
            russianTransliteration: "Астагфируллах",
            englishTranslation: "I seek forgiveness from Allah",
            russianTranslation: "Прошу прощения у Аллаха"
        ),
        KeyboardIslamicPhrase(
            key: "inshallah",
            arabic: "إن شاء الله",
            englishTransliteration: "InshaAllah",
            russianTransliteration: "ИншаАллах",
            englishTranslation: "If Allah wills",
            russianTranslation: "Если пожелает Аллах"
        ),
        KeyboardIslamicPhrase(
            key: "mashallah",
            arabic: "ما شاء الله",
            englishTransliteration: "MashaAllah",
            russianTransliteration: "МашаАллах",
            englishTranslation: "What Allah has willed",
            russianTranslation: "Как пожелал Аллах"
        ),
        KeyboardIslamicPhrase(
            key: "jazakallahu_khairan",
            arabic: "جزاك الله خيراً",
            englishTransliteration: "JazakAllahu Khairan",
            russianTransliteration: "Джазакаллаху хайран",
            englishTranslation: "May Allah reward you with good",
            russianTranslation: "Да воздаст тебе Аллах добром"
        ),
        KeyboardIslamicPhrase(
            key: "barakallahu_feek",
            arabic: "بارك الله فيك",
            englishTransliteration: "BarakAllahu Feek",
            russianTransliteration: "Баракаллаху фик",
            englishTranslation: "May Allah bless you",
            russianTranslation: "Да благословит тебя Аллах"
        ),
        KeyboardIslamicPhrase(
            key: "ameen",
            arabic: "آمين",
            englishTransliteration: "Ameen",
            russianTransliteration: "Аминь",
            englishTranslation: "Amen",
            russianTranslation: "Аминь"
        ),
        KeyboardIslamicPhrase(
            key: "la_hawla",
            arabic: "لا حول ولا قوة إلا بالله",
            englishTransliteration: "La hawla wa la quwwata illa billah",
            russianTransliteration: "Ля хауля уа ля куввата илля биллях",
            englishTranslation: "There is no power except with Allah",
            russianTranslation: "Нет силы кроме как у Аллаха"
        ),
        KeyboardIslamicPhrase(
            key: "tawakkaltu",
            arabic: "توكلت على الله",
            englishTransliteration: "Tawakkaltu 'ala Allah",
            russianTransliteration: "Таваккальту аля Аллах",
            englishTranslation: "I put my trust in Allah",
            russianTranslation: "Я полагаюсь на Аллаха"
        ),
        KeyboardIslamicPhrase(
            key: "rahimahu_allah",
            arabic: "رحمه الله",
            englishTransliteration: "Rahimahu Allah",
            russianTransliteration: "Рахимаху Аллах",
            englishTranslation: "May Allah have mercy on him",
            russianTranslation: "Да помилует его Аллах"
        ),
        KeyboardIslamicPhrase(
            key: "fi_amanillah",
            arabic: "في أمان الله",
            englishTransliteration: "Fi Amanillah",
            russianTransliteration: "Фи аманиллях",
            englishTranslation: "In Allah's protection",
            russianTranslation: "Под защитой Аллаха"
        ),
        KeyboardIslamicPhrase(
            key: "taqabbal_allah",
            arabic: "تقبل الله",
            englishTransliteration: "Taqabbal Allah",
            russianTransliteration: "ТакяббалАллах",
            englishTranslation: "May Allah accept",
            russianTranslation: "Да примет Аллах"
        ),
        KeyboardIslamicPhrase(
            key: "maa_salama",
            arabic: "مع السلامة",
            englishTransliteration: "Ma'a Salama",
            russianTransliteration: "Маа саляма",
            englishTranslation: "Go in peace",
            russianTranslation: "Иди с миром"
        ),
        KeyboardIslamicPhrase(
            key: "ya_allah",
            arabic: "يا الله",
            englishTransliteration: "Ya Allah",
            russianTransliteration: "Я Аллах",
            englishTranslation: "O Allah",
            russianTranslation: "О Аллах"
        )
    ]
    
    private init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.org.mels.keyboard.muslim") ?? UserDefaults.standard
    }
    
    var selectedPhrases: [KeyboardIslamicPhrase] {
        // Принудительно обновляем данные из UserDefaults каждый раз
        userDefaults.synchronize()

        print("🔍 KeyboardPhrasesManager: Looking for selected phrases...")

        // Пробуем ВСЕ возможные ключи для совместимости
        let possibleKeys = [
            "selected_islamic_phrases",           // Основной ключ из главного приложения
            "keyboard_selected_islamic_phrases",  // Дублирующий ключ
            selectedPhrasesKey                    // Наш ключ
        ]

        for key in possibleKeys {
            print("🔍 Checking key: '\(key)'")
            if let data = userDefaults.data(forKey: key) {
                print("📦 Found data for key '\(key)': \(data.count) bytes")
                if let selectedKeys = try? JSONDecoder().decode([String].self, from: data) {
                    print("✅ KeyboardPhrasesManager: Found data with key '\(key)': \(selectedKeys)")
                    let filtered = allPhrases.filter { selectedKeys.contains($0.key) }
                    if !filtered.isEmpty {
                        print("📊 KeyboardPhrasesManager: Returning \(filtered.count) selected phrases")
                        return filtered
                    }
                }
            } else {
                print("❌ No data found for key '\(key)'")
            }
        }

        print("⚠️ KeyboardPhrasesManager: No selected phrases found, using default first 6")
        // Default: return first 6 phrases
        return Array(allPhrases.prefix(6))
    }

    // Метод для принудительного обновления данных
    func refreshData() {
        print("🔄🔄🔄 KeyboardPhrasesManager: FORCE REFRESHING DATA!!! 🔄🔄🔄")

        // Принудительная синхронизация
        userDefaults.synchronize()

        // Проверяем ВСЕ возможные ключи
        let keys = [
            "selected_islamic_phrases",
            "keyboard_selected_islamic_phrases",
            selectedPhrasesKey
        ]

        var foundAnyData = false

        for key in keys {
            if let data = userDefaults.data(forKey: key) {
                print("📊 Found data for key '\(key)': \(data.count) bytes")
                if let selectedKeys = try? JSONDecoder().decode([String].self, from: data) {
                    print("   ✅ Decoded \(selectedKeys.count) keys: \(selectedKeys)")
                    foundAnyData = true
                } else {
                    print("   ❌ Failed to decode data for key '\(key)'")
                }
            } else {
                print("❌ No data found for key '\(key)'")
            }
        }

        if !foundAnyData {
            print("⚠️ NO DATA FOUND IN ANY KEY! Using defaults.")
        }

        print("✅ KeyboardPhrasesManager: Refresh completed")
    }
}

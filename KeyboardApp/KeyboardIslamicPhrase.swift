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
    let kazakhTransliteration: String
    let arabicTransliteration: String
    let englishTranslation: String
    let russianTranslation: String
    let kazakhTranslation: String
    let arabicTranslation: String
    let englishMeaning: String
    let russianMeaning: String
    let kazakhMeaning: String
    let arabicMeaning: String
    let englishUsage: String
    let russianUsage: String
    let kazakhUsage: String
    let arabicUsage: String

    // Convenience initializer for backward compatibility
    init(key: String, arabic: String, englishTransliteration: String, russianTransliteration: String,
         englishTranslation: String, russianTranslation: String, englishMeaning: String, russianMeaning: String,
         englishUsage: String, russianUsage: String,
         kazakhTransliteration: String? = nil, arabicTransliteration: String? = nil,
         kazakhTranslation: String? = nil, arabicTranslation: String? = nil,
         kazakhMeaning: String? = nil, arabicMeaning: String? = nil,
         kazakhUsage: String? = nil, arabicUsage: String? = nil) {
        self.key = key
        self.arabic = arabic
        self.englishTransliteration = englishTransliteration
        self.russianTransliteration = russianTransliteration
        self.kazakhTransliteration = kazakhTransliteration ?? russianTransliteration
        self.arabicTransliteration = arabicTransliteration ?? arabic
        self.englishTranslation = englishTranslation
        self.russianTranslation = russianTranslation
        self.kazakhTranslation = kazakhTranslation ?? russianTranslation
        self.arabicTranslation = arabicTranslation ?? arabic
        self.englishMeaning = englishMeaning
        self.russianMeaning = russianMeaning
        self.kazakhMeaning = kazakhMeaning ?? russianMeaning
        self.arabicMeaning = arabicMeaning ?? arabic
        self.englishUsage = englishUsage
        self.russianUsage = russianUsage
        self.kazakhUsage = kazakhUsage ?? russianUsage
        self.arabicUsage = arabicUsage ?? englishUsage
    }
    
    // Get transliteration based on current language
    func transliteration(for language: KeyboardLanguage) -> String {
        switch language {
        case .russian:
            return russianTransliteration
        case .english:
            return englishTransliteration
        case .kazakh:
            return kazakhTransliteration
        case .arabic:
            return arabicTransliteration
        case .french, .german, .chinese, .hindi, .kyrgyz, .uzbek, .korean, .urdu, .spanish, .italian:
            return englishTransliteration // Fallback to English for new languages
        }
    }

    // Get translation based on current language
    func translation(for language: KeyboardLanguage) -> String {
        switch language {
        case .russian:
            return russianTranslation
        case .english:
            return englishTranslation
        case .kazakh:
            return kazakhTranslation
        case .arabic:
            return arabicTranslation
        case .french, .german, .chinese, .hindi, .kyrgyz, .uzbek, .korean, .urdu, .spanish, .italian:
            return englishTranslation // Fallback to English for new languages
        }
    }

    // Get meaning based on current language
    func meaning(for language: KeyboardLanguage) -> String {
        switch language {
        case .russian:
            return russianMeaning
        case .english:
            return englishMeaning
        case .kazakh:
            return kazakhMeaning
        case .arabic:
            return arabicMeaning
        case .french, .german, .chinese, .hindi, .kyrgyz, .uzbek, .korean, .urdu, .spanish, .italian:
            return englishMeaning // Fallback to English for new languages
        }
    }

    // Get usage recommendations based on current language
    func usage(for language: KeyboardLanguage) -> String {
        switch language {
        case .russian:
            return russianUsage
        case .english:
            return englishUsage
        case .kazakh:
            return kazakhUsage
        case .arabic:
            return arabicUsage
        case .french, .german, .chinese, .hindi, .kyrgyz, .uzbek, .korean, .urdu, .spanish, .italian:
            return englishUsage // Fallback to English for new languages
        }
    }

    // Get display text for keyboard button
    func displayText(for language: KeyboardLanguage) -> String {
        // Для арабского языка проверяем режим отображения
        if language == .arabic {
            let displayMode = KeyboardLanguageManager.shared.arabicDisplayMode
            switch displayMode {
            case .arabic:
                return arabic
            case .englishTranslation:
                return translation(for: .english)
            }
        }
        return transliteration(for: language)
    }

    // Get text to insert when button is tapped
    func insertText(for language: KeyboardLanguage, useArabic: Bool) -> String {
        // Для арабского языка проверяем режим отображения
        if language == .arabic {
            let displayMode = KeyboardLanguageManager.shared.arabicDisplayMode
            switch displayMode {
            case .arabic:
                return arabic
            case .englishTranslation:
                return translation(for: .english)
            }
        }

        if useArabic {
            return arabic
        } else {
            return transliteration(for: language)
        }
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
            russianTransliteration: "Ассаляму 'аляйкум",
            englishTranslation: "Peace be upon you",
            russianTranslation: "Мир вам",
            englishMeaning: "Peace be upon you",
            russianMeaning: "Мир вам",
            englishUsage: "Greeting at the beginning of a conversation",
            russianUsage: "Приветствие в начале разговора",
            kazakhTransliteration: "Ассаляму 'аляйкум",
            kazakhTranslation: "Сізге бейбітшілік болсын",
            kazakhMeaning: "Сізге бейбітшілік болсын",
            kazakhUsage: "Сөйлесу басында сәлемдесу",
            arabicUsage: "تحية في بداية المحادثة"
        ),
        KeyboardIslamicPhrase(
            key: "wa_alaikum_assalam",
            arabic: "وعليكم السلام",
            englishTransliteration: "Wa Alaikum Assalam",
            russianTransliteration: "Уа 'аляйкум ассалям",
            englishTranslation: "And upon you peace",
            russianTranslation: "И вам мир",
            englishMeaning: "And upon you peace",
            russianMeaning: "И вам мир",
            englishUsage: "Response to Assalamu Alaikum",
            russianUsage: "Ответ на Assalamu Alaikum",
            kazakhTransliteration: "Уа 'аляйкум ассалям",
            kazakhTranslation: "Сізге де бейбітшілік",
            kazakhMeaning: "Сізге де бейбітшілік",
            kazakhUsage: "Ассаламу алейкумға жауап",
            arabicUsage: "رد على السلام عليكم"
        ),
        KeyboardIslamicPhrase(
            key: "bismillah",
            arabic: "بسم الله",
            englishTransliteration: "Bismillah",
            russianTransliteration: "Бисмилляh",
            englishTranslation: "In the name of Allah",
            russianTranslation: "Во имя Аллаха",
            englishMeaning: "In the name of Allah",
            russianMeaning: "Во имя Аллаха",
            englishUsage: "Before starting any task, eating, or sending a message ('Bismillah, I'm starting...')",
            russianUsage: "Перед началом дела, еды, сообщения («Bismillah, начинаю…»)"
        ),
        KeyboardIslamicPhrase(
            key: "alhamdulillah",
            arabic: "الحمد لله",
            englishTransliteration: "Alhamdulillah",
            russianTransliteration: "Альхамдулиллаh",
            englishTranslation: "Praise be to Allah",
            russianTranslation: "Хвала Аллаху",
            englishMeaning: "Praise be to Allah",
            russianMeaning: "Хвала Аллаху",
            englishUsage: "After good news, expressing gratitude",
            russianUsage: "После хороших новостей, благодарность"
        ),
        KeyboardIslamicPhrase(
            key: "subhanallah",
            arabic: "سبحان الله",
            englishTransliteration: "SubhanAllah",
            russianTransliteration: "СубхьанАллаh",
            englishTranslation: "Glory be to Allah",
            russianTranslation: "Слава Аллаху",
            englishMeaning: "Glory be to Allah",
            russianMeaning: "Пречист Аллах",
            englishUsage: "In amazement, admiration ('SubhanAllah, how beautiful!')",
            russianUsage: "В удивлении, восхищении («SubhanAllah, как красиво!»)"
        ),
        KeyboardIslamicPhrase(
            key: "allahu_akbar",
            arabic: "الله أكبر",
            englishTransliteration: "Allahu Akbar",
            russianTransliteration: "Аллаhу Акбар",
            englishTranslation: "Allah is the Greatest",
            russianTranslation: "Аллах велик",
            englishMeaning: "Allah is the Greatest",
            russianMeaning: "Аллах Велик",
            englishUsage: "In praise, strong emotions",
            russianUsage: "В восхвалении, сильных эмоциях"
        ),
        KeyboardIslamicPhrase(
            key: "la_ilaha_illallah",
            arabic: "لا إله إلا الله",
            englishTransliteration: "La ilaha illallah",
            russianTransliteration: "Ля иляха илляллах",
            englishTranslation: "There is no god but Allah",
            russianTranslation: "Нет бога кроме Аллаха",
            englishMeaning: "There is no god but Allah",
            russianMeaning: "Нет божества, кроме Аллаха",
            englishUsage: "In confirmation of faith, strengthening each other",
            russianUsage: "В подтверждении веры, укреплении друг друга"
        ),
        KeyboardIslamicPhrase(
            key: "astaghfirullah",
            arabic: "أستغفر الله",
            englishTransliteration: "Astaghfirullah",
            russianTransliteration: "Астагфируллах",
            englishTranslation: "I seek forgiveness from Allah",
            russianTranslation: "Прошу прощения у Аллаха",
            englishMeaning: "I seek forgiveness from Allah",
            russianMeaning: "Прошу прощения у Аллаха",
            englishUsage: "When making a mistake, expressing regret ('Astaghfirullah, forgive me...')",
            russianUsage: "При ошибке, сожалении («Astaghfirullah, прости меня…»)"
        ),
        KeyboardIslamicPhrase(
            key: "inshallah",
            arabic: "إن شاء الله",
            englishTransliteration: "InshaAllah",
            russianTransliteration: "ИншаАллах",
            englishTranslation: "If Allah wills",
            russianTranslation: "Если пожелает Аллах",
            englishMeaning: "If Allah wills",
            russianMeaning: "Если пожелает Аллах",
            englishUsage: "When making plans, agreements ('See you tomorrow, InshaAllah')",
            russianUsage: "При планах, договорённостях («Встретимся завтра, InshaAllah»)"
        ),
        KeyboardIslamicPhrase(
            key: "mashallah",
            arabic: "ما شاء الله",
            englishTransliteration: "MashaAllah",
            russianTransliteration: "МашаАллах",
            englishTranslation: "What Allah has willed",
            russianTranslation: "Как пожелал Аллах",
            englishMeaning: "What Allah has willed",
            russianMeaning: "Как пожелал Аллах",
            englishUsage: "When praising, to avoid envy ('MashaAllah, beautiful!')",
            russianUsage: "При похвале, чтобы избежать зависти («MashaAllah, красота!»)"
        ),
        KeyboardIslamicPhrase(
            key: "jazakallahu_khairan",
            arabic: "جزاك الله خيراً",
            englishTransliteration: "JazakAllahu Khairan",
            russianTransliteration: "Джазакаллаху хайран",
            englishTranslation: "May Allah reward you with good",
            russianTranslation: "Да воздаст тебе Аллах добром",
            englishMeaning: "May Allah reward you with good",
            russianMeaning: "Да воздаст тебе Аллах добром",
            englishUsage: "Gratitude for help, gifts",
            russianUsage: "Благодарность за помощь, подарок"
        ),
        KeyboardIslamicPhrase(
            key: "barakallahu_feek",
            arabic: "بارك الله فيك",
            englishTransliteration: "BarakAllahu Feek",
            russianTransliteration: "Баракаллаху фик",
            englishTranslation: "May Allah bless you",
            russianTranslation: "Да благословит тебя Аллах",
            englishMeaning: "May Allah bless you",
            russianMeaning: "Да благословит тебя Аллах",
            englishUsage: "Response to gratitude, wishing good",
            russianUsage: "Ответ на благодарность, пожелание добра"
        ),
        KeyboardIslamicPhrase(
            key: "ameen",
            arabic: "آمين",
            englishTransliteration: "Ameen",
            russianTransliteration: "Аминь",
            englishTranslation: "Amen",
            russianTranslation: "Аминь",
            englishMeaning: "Amen",
            russianMeaning: "Аминь",
            englishUsage: "At the end of dua (prayer)",
            russianUsage: "В завершение дуа (молитвы)"
        ),
        KeyboardIslamicPhrase(
            key: "la_hawla",
            arabic: "لا حول ولا قوة إلا بالله",
            englishTransliteration: "La hawla wa la quwwata illa billah",
            russianTransliteration: "Ля хауля уа ля куввата илля биллях",
            englishTranslation: "There is no power except with Allah",
            russianTranslation: "Нет силы кроме как у Аллаха",
            englishMeaning: "There is no power except with Allah",
            russianMeaning: "Нет силы, кроме как с Аллахом",
            englishUsage: "In difficult circumstances, seeking support",
            russianUsage: "При тяжёлых обстоятельствах, поиске поддержки"
        ),
        KeyboardIslamicPhrase(
            key: "tawakkaltu",
            arabic: "توكلت على الله",
            englishTransliteration: "Tawakkaltu 'ala Allah",
            russianTransliteration: "Таваккальту аля Аллах",
            englishTranslation: "I put my trust in Allah",
            russianTranslation: "Я полагаюсь на Аллаха",
            englishMeaning: "I put my trust in Allah",
            russianMeaning: "Полагаюсь на Аллаха",
            englishUsage: "When making decisions, trusting ('Tawakkaltu, may Allah's will be done')",
            russianUsage: "При принятии решения, доверии («Tawakkaltu, пусть будет воля Аллаха»)"
        ),
        KeyboardIslamicPhrase(
            key: "rahimahu_allah",
            arabic: "رحمه الله",
            englishTransliteration: "Rahimahu Allah",
            russianTransliteration: "Рахимаху Аллах",
            englishTranslation: "May Allah have mercy on him",
            russianTranslation: "Да помилует его Аллах",
            englishMeaning: "May Allah have mercy on him",
            russianMeaning: "Да помилует его Аллах",
            englishUsage: "About condolences, mentioning the deceased",
            russianUsage: "О соболезновании, упоминании умершего"
        ),
        KeyboardIslamicPhrase(
            key: "fi_amanillah",
            arabic: "في أمان الله",
            englishTransliteration: "Fi Amanillah",
            russianTransliteration: "Фи аманиллях",
            englishTranslation: "In Allah's protection",
            russianTranslation: "Под защитой Аллаха",
            englishMeaning: "In Allah's protection",
            russianMeaning: "В защите Аллаха",
            englishUsage: "Farewell, wishing safety ('Fi Amanillah, see you tomorrow')",
            russianUsage: "Прощание, пожелание безопасности («Fi Amanillah, до завтра»)"
        ),
        KeyboardIslamicPhrase(
            key: "taqabbal_allah",
            arabic: "تقبل الله",
            englishTransliteration: "Taqabbal Allah",
            russianTransliteration: "ТакяббалАллах",
            englishTranslation: "May Allah accept",
            russianTranslation: "Да примет Аллах",
            englishMeaning: "May Allah accept (your deeds)",
            russianMeaning: "Пусть Аллах примет (твои дела)",
            englishUsage: "After dua or good deeds",
            russianUsage: "После дуа или благих дел"
        ),
        KeyboardIslamicPhrase(
            key: "maa_salama",
            arabic: "مع السلامة",
            englishTransliteration: "Ma'a Salama",
            russianTransliteration: "Маа саляма",
            englishTranslation: "Go in peace",
            russianTranslation: "Иди с миром",
            englishMeaning: "Go in peace",
            russianMeaning: "С миром",
            englishUsage: "Farewell at the end of conversation",
            russianUsage: "Прощание в конце переписки"
        ),
        KeyboardIslamicPhrase(
            key: "ya_allah",
            arabic: "يا الله",
            englishTransliteration: "Ya Allah",
            russianTransliteration: "Я Аллах",
            englishTranslation: "O Allah",
            russianTranslation: "О Аллах",
            englishMeaning: "O Allah!",
            russianMeaning: "О Аллах!",
            englishUsage: "In exclamation, asking for help, strong feelings",
            russianUsage: "При восклицании, просьбе о помощи, сильном чувстве"
        ),

        // Islamic Symbols and Honorifics
        KeyboardIslamicPhrase(
            key: "sallallahu_alayhi_wa_sallam",
            arabic: "ﷺ",
            englishTransliteration: "ṣallallāhu 'alayhi wa sallam",
            russianTransliteration: "саллаллаху алейхи ва саллам",
            englishTranslation: "Peace and blessings of Allah be upon him",
            russianTranslation: "Мир и благословение Аллаха да будут над ним",
            englishMeaning: "Peace and blessings of Allah be upon him",
            russianMeaning: "Мир и благословение Аллаха да будут над ним",
            englishUsage: "Said after mentioning Prophet Muhammad (peace be upon him)",
            russianUsage: "Произносится после упоминания Пророка Мухаммада (мир ему)"
        ),

        KeyboardIslamicPhrase(
            key: "alayhi_salam",
            arabic: "عليه السلام",
            englishTransliteration: "'alayhi'l-salām",
            russianTransliteration: "алейхи салям",
            englishTranslation: "Peace be upon him",
            russianTranslation: "Мир да будет над ним",
            englishMeaning: "Peace be upon him",
            russianMeaning: "Мир да будет над ним",
            englishUsage: "Said after mentioning prophets and angels",
            russianUsage: "Произносится после упоминания пророков и ангелов"
        ),

        KeyboardIslamicPhrase(
            key: "radiyallahu_anhum",
            arabic: "رضي الله عنهم",
            englishTransliteration: "raḍyAllāhu 'anhum",
            russianTransliteration: "радыйаллаху анхум",
            englishTranslation: "May Allah be pleased with them",
            russianTranslation: "Пусть Аллах будет доволен ими",
            englishMeaning: "May Allah be pleased with them",
            russianMeaning: "Пусть Аллах будет доволен ими",
            englishUsage: "Said after mentioning the companions of the Prophet",
            russianUsage: "Произносится после упоминания сподвижников Пророка"
        ),

        KeyboardIslamicPhrase(
            key: "subhanahu_wa_taala",
            arabic: "سبحانه وتعالى",
            englishTransliteration: "subḥānahu wa taʿālā",
            russianTransliteration: "субханаху ва тааля",
            englishTranslation: "Glory be to Him, the Exalted",
            russianTranslation: "Пречист и Возвышен Он",
            englishMeaning: "Glory be to Him, the Exalted",
            russianMeaning: "Пречист и Возвышен Он",
            englishUsage: "Said after mentioning Allah",
            russianUsage: "Произносится после упоминания Аллаха"
        )
    ]
    
    private init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
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

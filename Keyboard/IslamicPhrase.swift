//
//  IslamicPhrase.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import Foundation

struct IslamicPhrase: Identifiable, Codable {
    var id: UUID = UUID()
    let key: String
    let arabic: String
    let englishTransliteration: String
    let russianTransliteration: String
    let kazakhTransliteration: String
    let arabicTransliteration: String
    let englishMeaning: String
    let russianMeaning: String
    let kazakhMeaning: String
    let arabicMeaning: String
    let englishTranslation: String
    let russianTranslation: String
    let kazakhTranslation: String
    let arabicTranslation: String
    let englishUsage: String
    let russianUsage: String
    let kazakhUsage: String
    let arabicUsage: String
    var isSelected: Bool = false

    // Convenience initializer for backward compatibility
    init(key: String, arabic: String, englishTransliteration: String, russianTransliteration: String,
         englishMeaning: String, russianMeaning: String, englishUsage: String, russianUsage: String,
         kazakhTransliteration: String? = nil, arabicTransliteration: String? = nil,
         kazakhMeaning: String? = nil, arabicMeaning: String? = nil,
         englishTranslation: String? = nil, russianTranslation: String? = nil,
         kazakhTranslation: String? = nil, arabicTranslation: String? = nil,
         kazakhUsage: String? = nil, arabicUsage: String? = nil, isSelected: Bool = false) {
        self.key = key
        self.arabic = arabic
        self.englishTransliteration = englishTransliteration
        self.russianTransliteration = russianTransliteration
        self.kazakhTransliteration = kazakhTransliteration ?? russianTransliteration
        self.arabicTransliteration = arabicTransliteration ?? arabic
        self.englishMeaning = englishMeaning
        self.russianMeaning = russianMeaning
        self.kazakhMeaning = kazakhMeaning ?? russianMeaning
        self.arabicMeaning = arabicMeaning ?? arabic
        self.englishTranslation = englishTranslation ?? englishMeaning
        self.russianTranslation = russianTranslation ?? russianMeaning
        self.kazakhTranslation = kazakhTranslation ?? (kazakhMeaning ?? russianMeaning)
        self.arabicTranslation = arabicTranslation ?? (arabicMeaning ?? arabic)
        self.englishUsage = englishUsage
        self.russianUsage = russianUsage
        self.kazakhUsage = kazakhUsage ?? russianUsage
        self.arabicUsage = arabicUsage ?? englishUsage
        self.isSelected = isSelected
    }

    // Full initializer
    init(key: String, arabic: String, englishTransliteration: String, russianTransliteration: String,
         kazakhTransliteration: String, arabicTransliteration: String, englishMeaning: String, russianMeaning: String,
         kazakhMeaning: String, arabicMeaning: String, englishTranslation: String, russianTranslation: String,
         kazakhTranslation: String, arabicTranslation: String, englishUsage: String, russianUsage: String,
         kazakhUsage: String, arabicUsage: String, isSelected: Bool = false) {
        self.key = key
        self.arabic = arabic
        self.englishTransliteration = englishTransliteration
        self.russianTransliteration = russianTransliteration
        self.kazakhTransliteration = kazakhTransliteration
        self.arabicTransliteration = arabicTransliteration
        self.englishMeaning = englishMeaning
        self.russianMeaning = russianMeaning
        self.kazakhMeaning = kazakhMeaning
        self.arabicMeaning = arabicMeaning
        self.englishTranslation = englishTranslation
        self.russianTranslation = russianTranslation
        self.kazakhTranslation = kazakhTranslation
        self.arabicTranslation = arabicTranslation
        self.englishUsage = englishUsage
        self.russianUsage = russianUsage
        self.kazakhUsage = kazakhUsage
        self.arabicUsage = arabicUsage
        self.isSelected = isSelected
    }

    // Get transliteration based on current language
    var transliteration: String {
        let currentLanguage = LanguageManager.shared.currentLanguage
        switch currentLanguage {
        case .russian:
            return russianTransliteration
        case .english:
            return englishTransliteration
        case .kazakh:
            return kazakhTransliteration
        case .arabic:
            return arabicTransliteration
        }
    }

    // Get meaning based on current language
    var meaning: String {
        let currentLanguage = LanguageManager.shared.currentLanguage
        switch currentLanguage {
        case .russian:
            return russianMeaning
        case .english:
            return englishMeaning
        case .kazakh:
            return kazakhMeaning
        case .arabic:
            return arabicMeaning
        }
    }

    // Get usage recommendations based on current language
    var usage: String {
        let currentLanguage = LanguageManager.shared.currentLanguage
        switch currentLanguage {
        case .russian:
            return russianUsage
        case .english:
            return englishUsage
        case .kazakh:
            return kazakhUsage
        case .arabic:
            return arabicUsage
        }
    }

    // Get translation based on specific language
    func translation(for language: AppLanguage) -> String {
        switch language {
        case .russian:
            return russianTranslation
        case .english:
            return englishTranslation
        case .kazakh:
            return kazakhTranslation
        case .arabic:
            return arabicTranslation
        }
    }

    // Localized display text
    var localizedText: String {
        return NSLocalizedString("phrase_\(key)", comment: "")
    }

    // Display format combining all versions
    var displayText: String {
        let currentLanguage = LanguageManager.shared.currentLanguage

        // Для арабского языка проверяем режим отображения
        if currentLanguage == .arabic {
            let displayMode = LanguageManager.shared.arabicDisplayMode
            switch displayMode {
            case .arabic:
                return "\(arabic) • \(transliteration) • \(localizedText)"
            case .englishTranslation:
                return "\(translation(for: .english)) • \(transliteration) • \(localizedText)"
            }
        }

        return "\(arabic) • \(transliteration) • \(localizedText)"
    }
}

class IslamicPhrasesManager: ObservableObject {
    @Published var phrases: [IslamicPhrase] = []
    
    let userDefaults: UserDefaults
    private let selectedPhrasesKey = "selected_islamic_phrases"

    init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
        loadPhrases()
        loadSelectedPhrases()
    }
    
    private func loadPhrases() {
        phrases = [
            IslamicPhrase(
                key: "assalamu_alaikum",
                arabic: "السلام عليكم",
                englishTransliteration: "Assalamu Alaikum",
                russianTransliteration: "Ассаламу алейкум",
                englishMeaning: "Peace be upon you",
                russianMeaning: "Мир вам",
                englishUsage: "Greeting at the beginning of a conversation",
                russianUsage: "Приветствие в начале разговора",
                kazakhTransliteration: "Ассаламу алейкум",
                arabicTransliteration: "السلام عليكم",
                kazakhMeaning: "Сізге бейбітшілік болсын",
                arabicMeaning: "السلام عليكم",
                kazakhUsage: "Сөйлесу басында сәлемдесу",
                arabicUsage: "تحية في بداية المحادثة"
            ),
            IslamicPhrase(
                key: "wa_alaikum_assalam",
                arabic: "وعليكم السلام",
                englishTransliteration: "Wa Alaikum Assalam",
                russianTransliteration: "Уа алейкум ассалям",
                englishMeaning: "And upon you peace",
                russianMeaning: "И вам мир",
                englishUsage: "Response to Assalamu Alaikum",
                russianUsage: "Ответ на Assalamu Alaikum"
            ),
            IslamicPhrase(
                key: "bismillah",
                arabic: "بسم الله",
                englishTransliteration: "Bismillah",
                russianTransliteration: "Бисмиллях",
                englishMeaning: "In the name of Allah",
                russianMeaning: "Во имя Аллаха",
                englishUsage: "Before starting any task, eating, or sending a message ('Bismillah, I'm starting...')",
                russianUsage: "Перед началом дела, еды, сообщения («Bismillah, начинаю…»)"
            ),
            IslamicPhrase(
                key: "alhamdulillah",
                arabic: "الحمد لله",
                englishTransliteration: "Alhamdulillah",
                russianTransliteration: "Альхамдулиллях",
                englishMeaning: "Praise be to Allah",
                russianMeaning: "Хвала Аллаху",
                englishUsage: "After good news, expressing gratitude",
                russianUsage: "После хороших новостей, благодарность"
            ),
            IslamicPhrase(
                key: "subhanallah",
                arabic: "سبحان الله",
                englishTransliteration: "SubhanAllah",
                russianTransliteration: "Субханаллах",
                englishMeaning: "Glory be to Allah",
                russianMeaning: "Пречист Аллах",
                englishUsage: "In amazement, admiration ('SubhanAllah, how beautiful!')",
                russianUsage: "В удивлении, восхищении («SubhanAllah, как красиво!»)"
            ),
            IslamicPhrase(
                key: "allahu_akbar",
                arabic: "الله أكبر",
                englishTransliteration: "Allahu Akbar",
                russianTransliteration: "Аллаху Акбар",
                englishMeaning: "Allah is the Greatest",
                russianMeaning: "Аллах Велик",
                englishUsage: "In praise, strong emotions",
                russianUsage: "В восхвалении, сильных эмоциях"
            ),
            IslamicPhrase(
                key: "la_ilaha_illallah",
                arabic: "لا إله إلا الله",
                englishTransliteration: "La ilaha illallah",
                russianTransliteration: "Ля иляха илляллах",
                englishMeaning: "There is no god but Allah",
                russianMeaning: "Нет божества, кроме Аллаха",
                englishUsage: "In confirmation of faith, strengthening each other",
                russianUsage: "В подтверждении веры, укреплении друг друга"
            ),
            IslamicPhrase(
                key: "astaghfirullah",
                arabic: "أستغفر الله",
                englishTransliteration: "Astaghfirullah",
                russianTransliteration: "Астагфируллах",
                englishMeaning: "I seek forgiveness from Allah",
                russianMeaning: "Прошу прощения у Аллаха",
                englishUsage: "When making a mistake, expressing regret ('Astaghfirullah, forgive me...')",
                russianUsage: "При ошибке, сожалении («Astaghfirullah, прости меня…»)"
            ),
            IslamicPhrase(
                key: "inshallah",
                arabic: "إن شاء الله",
                englishTransliteration: "InshaAllah",
                russianTransliteration: "ИншаАллах",
                englishMeaning: "If Allah wills",
                russianMeaning: "Если пожелает Аллах",
                englishUsage: "When making plans, agreements ('See you tomorrow, InshaAllah')",
                russianUsage: "При планах, договорённостях («Встретимся завтра, InshaAllah»)"
            ),
            IslamicPhrase(
                key: "mashallah",
                arabic: "ما شاء الله",
                englishTransliteration: "MashaAllah",
                russianTransliteration: "МашаАллах",
                englishMeaning: "What Allah has willed",
                russianMeaning: "Как пожелал Аллах",
                englishUsage: "When praising, to avoid envy ('MashaAllah, beautiful!')",
                russianUsage: "При похвале, чтобы избежать зависти («MashaAllah, красота!»)"
            ),
            IslamicPhrase(
                key: "jazakallahu_khairan",
                arabic: "جزاك الله خيراً",
                englishTransliteration: "JazakAllahu Khairan",
                russianTransliteration: "Джазакаллаху хайран",
                englishMeaning: "May Allah reward you with good",
                russianMeaning: "Да воздаст тебе Аллах добром",
                englishUsage: "Gratitude for help, gifts",
                russianUsage: "Благодарность за помощь, подарок"
            ),
            IslamicPhrase(
                key: "barakallahu_feek",
                arabic: "بارك الله فيك",
                englishTransliteration: "BarakAllahu Feek",
                russianTransliteration: "Баракаллаху фик",
                englishMeaning: "May Allah bless you",
                russianMeaning: "Да благословит тебя Аллах",
                englishUsage: "Response to gratitude, wishing good",
                russianUsage: "Ответ на благодарность, пожелание добра"
            ),
            IslamicPhrase(
                key: "ameen",
                arabic: "آمين",
                englishTransliteration: "Ameen",
                russianTransliteration: "Аминь",
                englishMeaning: "Amen",
                russianMeaning: "Аминь",
                englishUsage: "At the end of dua (prayer)",
                russianUsage: "В завершение дуа (молитвы)"
            ),
            IslamicPhrase(
                key: "la_hawla",
                arabic: "لا حول ولا قوة إلا بالله",
                englishTransliteration: "La hawla wa la quwwata illa billah",
                russianTransliteration: "Ля хауля уа ля куввата илля биллях",
                englishMeaning: "There is no power except with Allah",
                russianMeaning: "Нет силы, кроме как с Аллахом",
                englishUsage: "In difficult circumstances, seeking support",
                russianUsage: "При тяжёлых обстоятельствах, поиске поддержки"
            ),
            IslamicPhrase(
                key: "tawakkaltu",
                arabic: "توكلت على الله",
                englishTransliteration: "Tawakkaltu 'ala Allah",
                russianTransliteration: "Таваккальту аля Аллах",
                englishMeaning: "I put my trust in Allah",
                russianMeaning: "Полагаюсь на Аллаха",
                englishUsage: "When making decisions, trusting ('Tawakkaltu, may Allah's will be done')",
                russianUsage: "При принятии решения, доверии («Tawakkaltu, пусть будет воля Аллаха»)"
            ),
            IslamicPhrase(
                key: "rahimahu_allah",
                arabic: "رحمه الله",
                englishTransliteration: "Rahimahu Allah",
                russianTransliteration: "Рахимаху Аллах",
                englishMeaning: "May Allah have mercy on him",
                russianMeaning: "Да помилует его Аллах",
                englishUsage: "About condolences, mentioning the deceased",
                russianUsage: "О соболезновании, упоминании умершего"
            ),
            IslamicPhrase(
                key: "fi_amanillah",
                arabic: "في أمان الله",
                englishTransliteration: "Fi Amanillah",
                russianTransliteration: "Фи аманиллях",
                englishMeaning: "In Allah's protection",
                russianMeaning: "В защите Аллаха",
                englishUsage: "Farewell, wishing safety ('Fi Amanillah, see you tomorrow')",
                russianUsage: "Прощание, пожелание безопасности («Fi Amanillah, до завтра»)"
            ),
            IslamicPhrase(
                key: "taqabbal_allah",
                arabic: "تقبل الله",
                englishTransliteration: "Taqabbal Allah",
                russianTransliteration: "ТакяббалАллах",
                englishMeaning: "May Allah accept (your deeds)",
                russianMeaning: "Пусть Аллах примет (твои дела)",
                englishUsage: "After dua or good deeds",
                russianUsage: "После дуа или благих дел"
            ),
            IslamicPhrase(
                key: "maa_salama",
                arabic: "مع السلامة",
                englishTransliteration: "Ma'a Salama",
                russianTransliteration: "Маа саляма",
                englishMeaning: "Go in peace",
                russianMeaning: "С миром",
                englishUsage: "Farewell at the end of conversation",
                russianUsage: "Прощание в конце переписки"
            ),
            IslamicPhrase(
                key: "ya_allah",
                arabic: "يا الله",
                englishTransliteration: "Ya Allah",
                russianTransliteration: "Я Аллах",
                englishMeaning: "O Allah!",
                russianMeaning: "О Аллах!",
                englishUsage: "In exclamation, asking for help, strong feelings",
                russianUsage: "При восклицании, просьбе о помощи, сильном чувстве"
            ),

            // Islamic Symbols and Honorifics
            IslamicPhrase(
                key: "sallallahu_alayhi_wa_sallam",
                arabic: "ﷺ",
                englishTransliteration: "ṣallallāhu 'alayhi wa sallam",
                russianTransliteration: "саллаллаху алейхи ва саллам",
                englishMeaning: "Peace and blessings of Allah be upon him",
                russianMeaning: "Мир и благословение Аллаха да будут над ним",
                englishUsage: "Said after mentioning Prophet Muhammad (peace be upon him)",
                russianUsage: "Произносится после упоминания Пророка Мухаммада (мир ему)"
            ),

            IslamicPhrase(
                key: "alayhi_salam",
                arabic: "عليه السلام",
                englishTransliteration: "'alayhi'l-salām",
                russianTransliteration: "алейхи салям",
                englishMeaning: "Peace be upon him",
                russianMeaning: "Мир да будет над ним",
                englishUsage: "Said after mentioning prophets and angels",
                russianUsage: "Произносится после упоминания пророков и ангелов"
            ),

            IslamicPhrase(
                key: "radiyallahu_anhum",
                arabic: "رضي الله عنهم",
                englishTransliteration: "raḍyAllāhu 'anhum",
                russianTransliteration: "радыйаллаху анхум",
                englishMeaning: "May Allah be pleased with them",
                russianMeaning: "Пусть Аллах будет доволен ими",
                englishUsage: "Said after mentioning the companions of the Prophet",
                russianUsage: "Произносится после упоминания сподвижников Пророка"
            ),

            IslamicPhrase(
                key: "subhanahu_wa_taala",
                arabic: "سبحانه وتعالى",
                englishTransliteration: "subḥānahu wa taʿālā",
                russianTransliteration: "субханаху ва тааля",
                englishMeaning: "Glory be to Him, the Exalted",
                russianMeaning: "Пречист и Возвышен Он",
                englishUsage: "Said after mentioning Allah",
                russianUsage: "Произносится после упоминания Аллаха"
            )
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

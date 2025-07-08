//
//  Dua.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import Foundation

struct Dua: Identifiable, Codable {
    let id = UUID()
    let key: String
    let icon: String
    let englishTitle: String
    let russianTitle: String
    let arabicText: String
    let englishTranslation: String
    let russianTranslation: String
    let englishUsage: String
    let russianUsage: String
    var isSelected: Bool = false
    
    // Get title based on current language
    var title: String {
        let currentLanguage = LanguageManager.shared.currentLanguage
        switch currentLanguage {
        case .russian:
            return russianTitle
        case .english:
            return englishTitle
        }
    }
    
    // Get translation based on current language
    var translation: String {
        let currentLanguage = LanguageManager.shared.currentLanguage
        switch currentLanguage {
        case .russian:
            return russianTranslation
        case .english:
            return englishTranslation
        }
    }
    
    // Get usage description based on current language
    var usage: String {
        let currentLanguage = LanguageManager.shared.currentLanguage
        switch currentLanguage {
        case .russian:
            return russianUsage
        case .english:
            return englishUsage
        }
    }
    
    // Text to insert in chat
    var chatText: String {
        let currentLanguage = LanguageManager.shared.currentLanguage
        switch currentLanguage {
        case .russian:
            return "Дуа: \(russianTitle)"
        case .english:
            return "Dua: \(englishTitle)"
        }
    }
}

class DuaManager: ObservableObject {
    static let shared = DuaManager()

    @Published var duas: [Dua] = []
    private let userDefaults: UserDefaults
    private let selectedDuasKey = "keyboard_selected_duas"

    var selectedDuas: [Dua] {
        return duas.filter { $0.isSelected }
    }

    private init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
        loadDuas()
        loadSelectedDuas()
    }

    func toggleDuaSelection(_ dua: Dua) {
        if let index = duas.firstIndex(where: { $0.id == dua.id }) {
            duas[index].isSelected.toggle()
            saveSelectedDuas()
        }
    }

    private func saveSelectedDuas() {
        let selectedKeys = duas.filter { $0.isSelected }.map { $0.key }
        if let encoded = try? JSONEncoder().encode(selectedKeys) {
            userDefaults.set(encoded, forKey: selectedDuasKey)
            userDefaults.synchronize()
        }
        print("🔄 DuaManager: Saved \(selectedKeys.count) selected duas: \(selectedKeys)")
    }

    private func loadSelectedDuas() {
        if let data = userDefaults.data(forKey: selectedDuasKey),
           let selectedKeys = try? JSONDecoder().decode([String].self, from: data) {
            for i in 0..<duas.count {
                duas[i].isSelected = selectedKeys.contains(duas[i].key)
            }
            print("🔄 DuaManager: Loaded \(selectedKeys.count) selected duas: \(selectedKeys)")
        } else {
            // По умолчанию выбираем первые 5 дуа
            for i in 0..<min(5, duas.count) {
                duas[i].isSelected = true
            }
            saveSelectedDuas()
        }
    }

    func refreshData() {
        loadSelectedDuas()
    }
    
    private func loadDuas() {
        duas = [
            Dua(
                key: "success",
                icon: "star.fill",
                englishTitle: "Wish Success",
                russianTitle: "Пожелать удачи",
                arabicText: "اللهم وفقه لما تحب وترضى",
                englishTranslation: "O Allah, grant him success in what You love and are pleased with",
                russianTranslation: "О Аллах, даруй ему успех в том, что Ты любишь и чем доволен",
                englishUsage: "When wishing someone success in their endeavors",
                russianUsage: "Когда желаете кому-то успеха в делах"
            ),
            Dua(
                key: "health",
                icon: "heart.fill",
                englishTitle: "For Health",
                russianTitle: "За здоровье",
                arabicText: "اللهم اشفه شفاءً لا يغادر سقماً",
                englishTranslation: "O Allah, heal him with a healing that leaves no illness",
                russianTranslation: "О Аллах, исцели его исцелением, после которого не будет болезни",
                englishUsage: "When praying for someone's health and recovery",
                russianUsage: "Когда молитесь за чьё-то здоровье и выздоровление"
            ),
            Dua(
                key: "blessing",
                icon: "hands.and.sparkles.fill",
                englishTitle: "For Brother/Sister",
                russianTitle: "За брата/сестру",
                arabicText: "اللهم بارك له ووفقه",
                englishTranslation: "O Allah, bless him and grant him success",
                russianTranslation: "О Аллах, благослови его и даруй успех",
                englishUsage: "General blessing for a fellow Muslim",
                russianUsage: "Общее благословение для собрата-мусульманина"
            ),
            Dua(
                key: "start_task",
                icon: "play.fill",
                englishTitle: "Starting a Task",
                russianTitle: "Начать дело",
                arabicText: "بسم الله توكلت على الله",
                englishTranslation: "In the name of Allah, I place my trust in Allah",
                russianTranslation: "С именем Аллаха, я полагаюсь на Аллаха",
                englishUsage: "Before starting any important task or work",
                russianUsage: "Перед началом любого важного дела или работы"
            ),
            Dua(
                key: "comfort",
                icon: "shield.fill",
                englishTitle: "For Comfort",
                russianTitle: "Успокоить",
                arabicText: "حسبنا الله ونعم الوكيل",
                englishTranslation: "Allah is sufficient for us, and He is the best Disposer of affairs",
                russianTranslation: "Доволен нам Аллах, и прекрасный Он Покровитель",
                englishUsage: "In times of difficulty or when seeking Allah's protection",
                russianUsage: "В трудные времена или когда ищете защиты Аллаха"
            ),
            Dua(
                key: "travel",
                icon: "car.fill",
                englishTitle: "For Travel",
                russianTitle: "В путь",
                arabicText: "اللهم إنا نسألك في سفرنا هذا البر والتقوى",
                englishTranslation: "O Allah, we ask You for righteousness and piety in this journey",
                russianTranslation: "О Аллах, даруй нам благочестие в этом пути",
                englishUsage: "Before starting a journey or travel",
                russianUsage: "Перед началом путешествия или поездки"
            ),
            Dua(
                key: "forgiveness",
                icon: "square.fill",
                englishTitle: "Seeking Forgiveness",
                russianTitle: "Прощение",
                arabicText: "أستغفر الله",
                englishTranslation: "I seek forgiveness from Allah",
                russianTranslation: "Прошу прощения у Аллаха",
                englishUsage: "When seeking Allah's forgiveness",
                russianUsage: "Когда просите прощения у Аллаха"
            ),
            Dua(
                key: "beauty",
                icon: "sparkles",
                englishTitle: "Admiring Beauty",
                russianTitle: "Красота (МашаАллах)",
                arabicText: "ما شاء الله لا قوة إلا بالله",
                englishTranslation: "What Allah has willed. There is no power except with Allah",
                russianTranslation: "То, что пожелал Аллах. Нет мощи и силы, кроме как у Аллаха",
                englishUsage: "When admiring something beautiful to avoid evil eye",
                russianUsage: "При восхищении чем-то красивым, чтобы избежать сглаза"
            ),
            Dua(
                key: "barakah",
                icon: "gift.fill",
                englishTitle: "For Blessing",
                russianTitle: "Баррака",
                arabicText: "اللهم بارك",
                englishTranslation: "O Allah, grant blessing",
                russianTranslation: "О Аллах, даруй благодать",
                englishUsage: "When asking for Allah's blessing on something",
                russianUsage: "Когда просите благословения Аллаха на что-то"
            ),
            Dua(
                key: "sisters",
                icon: "person.2.fill",
                englishTitle: "For Sisters",
                russianTitle: "За сестер",
                arabicText: "اللهم احفظ أخواتنا",
                englishTranslation: "O Allah, protect our sisters",
                russianTranslation: "О Аллах, оберегай наших сестёр",
                englishUsage: "When praying for Muslim sisters",
                russianUsage: "Когда молитесь за сестёр-мусульманок"
            ),
            Dua(
                key: "knowledge",
                icon: "book.fill",
                englishTitle: "Before Study",
                russianTitle: "Перед учёбой",
                arabicText: "رب زدني علما",
                englishTranslation: "My Lord, increase me in knowledge",
                russianTranslation: "Господи, увеличь мои знания",
                englishUsage: "Before studying or seeking knowledge",
                russianUsage: "Перед учёбой или поиском знаний"
            ),
            Dua(
                key: "guidance",
                icon: "location.fill",
                englishTitle: "For Guidance",
                russianTitle: "За наставление",
                arabicText: "اللهم اهدنا الصراط المستقيم",
                englishTranslation: "O Allah, guide us to the straight path",
                russianTranslation: "О Аллах, веди нас прямым путём",
                englishUsage: "When seeking Allah's guidance",
                russianUsage: "Когда ищете наставления Аллаха"
            ),
            Dua(
                key: "grief",
                icon: "drop.fill",
                englishTitle: "In Times of Grief",
                russianTitle: "При горе",
                arabicText: "إنا لله وإنا إليه راجعون",
                englishTranslation: "Indeed, we belong to Allah and to Him we shall return",
                russianTranslation: "Поистине, мы принадлежим Аллаху и к Нему возвращаемся",
                englishUsage: "In times of loss or difficulty",
                russianUsage: "Во времена потери или трудностей"
            ),
            Dua(
                key: "night",
                icon: "moon.fill",
                englishTitle: "Good Night",
                russianTitle: "Спокойной ночи",
                arabicText: "باسمك اللهم أموت وأحيا",
                englishTranslation: "In Your name, O Allah, I die and I live",
                russianTranslation: "С Твоим именем, о Аллах, я умираю и живу",
                englishUsage: "Before going to sleep",
                russianUsage: "Перед сном"
            ),
            Dua(
                key: "morning",
                icon: "sun.max.fill",
                englishTitle: "Morning",
                russianTitle: "Утро",
                arabicText: "اللهم بك أصبحنا وبك أمسينا",
                englishTranslation: "O Allah, with You we begin our morning and with You we end our evening",
                russianTranslation: "С Тобой мы встречаем утро и вечер",
                englishUsage: "Morning remembrance",
                russianUsage: "Утреннее поминание"
            ),
            Dua(
                key: "duaa_protection_blessing",
                icon: "shield.checkered",
                englishTitle: "Protection from Loss",
                russianTitle: "Защита от потерь",
                arabicText: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ",
                englishTranslation: "Allahumma inni a'udhu bika min zawali ni'matika, wa tahawwuli 'afiyatika, wa fuja'ati niqmatika, wa jami'i sakhatika",
                russianTranslation: "Аллахумма инни а'удзу бика мин завали ни'матика, ва тахаввули 'афийатика, ва фуджаати никматика, ва джами'и сахатика",
                englishUsage: "When you're afraid of losing blessings, or for protection from Allah's anger and punishment. Good for hard times or expressing concern.",
                russianUsage: "Когда боишься потерять блага, или для защиты от гнева и наказания Аллаха. Подходит для трудных времён или выражения беспокойства."
            ),
            Dua(
                key: "may_allah_return_more",
                icon: "gift.circle.fill",
                englishTitle: "May Allah Reward You",
                russianTitle: "Да воздаст Аллах",
                arabicText: "أَثَابَكَ اللَّهُ",
                englishTranslation: "Athabaka Allahu",
                russianTranslation: "Асабака Аллаху",
                englishUsage: "When someone makes dua for you or does good to you. Islamic way of saying thank you.",
                russianUsage: "Когда кто-то делает дуа за тебя или делает добро. Исламский способ сказать спасибо."
            ),
            Dua(
                key: "duaa_against_evil_eye",
                icon: "eye.slash.fill",
                englishTitle: "Against Evil Eye",
                russianTitle: "От сглаза",
                arabicText: "اللَّهُمَّ بَارِكْ فِيهِ",
                englishTranslation: "Allahumma barik fihi",
                russianTranslation: "Аллахумма барик фихи",
                englishUsage: "When you fear you might give evil eye, for example when admiring someone.",
                russianUsage: "Когда боишься, что можешь сглазить, например, при восхищении кем-то."
            ),
            Dua(
                key: "take_care",
                icon: "shield.lefthalf.filled",
                englishTitle: "Take Care",
                russianTitle: "Береги себя",
                arabicText: "بِأَمَانِ اللَّهِ",
                englishTranslation: "Bi amaani-llah",
                russianTranslation: "Би амани Ллях",
                englishUsage: "As farewell, wishing safety, especially when traveling.",
                russianUsage: "Как прощание, пожелание безопасности, особенно в пути."
            )
        ]
    }
}

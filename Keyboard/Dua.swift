//
//  Dua.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import Foundation

struct Dua: Identifiable, Codable {
    var id: UUID = UUID()
    let key: String
    let icon: String
    let englishTitle: String
    let russianTitle: String
    let kazakhTitle: String
    let arabicTitle: String
    let arabicText: String
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
    init(key: String, icon: String, englishTitle: String, russianTitle: String, arabicText: String,
         englishTranslation: String, russianTranslation: String, englishUsage: String, russianUsage: String,
         kazakhTitle: String? = nil, arabicTitle: String? = nil,
         kazakhTranslation: String? = nil, arabicTranslation: String? = nil,
         kazakhUsage: String? = nil, arabicUsage: String? = nil, isSelected: Bool = false) {
        self.key = key
        self.icon = icon
        self.englishTitle = englishTitle
        self.russianTitle = russianTitle
        self.kazakhTitle = kazakhTitle ?? russianTitle
        self.arabicTitle = arabicTitle ?? englishTitle
        self.arabicText = arabicText
        self.englishTranslation = englishTranslation
        self.russianTranslation = russianTranslation
        self.kazakhTranslation = kazakhTranslation ?? russianTranslation
        self.arabicTranslation = arabicTranslation ?? arabicText
        self.englishUsage = englishUsage
        self.russianUsage = russianUsage
        self.kazakhUsage = kazakhUsage ?? russianUsage
        self.arabicUsage = arabicUsage ?? englishUsage
        self.isSelected = isSelected
    }

    // Full initializer
    init(key: String, icon: String, englishTitle: String, russianTitle: String, kazakhTitle: String, arabicTitle: String,
         arabicText: String, englishTranslation: String, russianTranslation: String, kazakhTranslation: String, arabicTranslation: String,
         englishUsage: String, russianUsage: String, kazakhUsage: String, arabicUsage: String, isSelected: Bool = false) {
        self.key = key
        self.icon = icon
        self.englishTitle = englishTitle
        self.russianTitle = russianTitle
        self.kazakhTitle = kazakhTitle
        self.arabicTitle = arabicTitle
        self.arabicText = arabicText
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
    
    // Get title based on current language
    var title: String {
        let currentLanguage = LanguageManager.shared.currentLanguage
        switch currentLanguage {
        case .russian:
            return russianTitle
        case .english:
            return englishTitle
        case .kazakh:
            return kazakhTitle
        case .arabic:
            return arabicTitle
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
        case .kazakh:
            return kazakhTranslation
        case .arabic:
            return arabicTranslation
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
        case .kazakh:
            return kazakhUsage
        case .arabic:
            return arabicUsage
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
        case .kazakh:
            return "Дұға: \(kazakhTitle)"
        case .arabic:
            return "دعاء: \(arabicTitle)"
        }
    }

    // Get display text based on Arabic language preference for duas
    var displayText: String {
        let currentLanguage = LanguageManager.shared.currentLanguage

        // Для арабского языка проверяем режим отображения
        if currentLanguage == .arabic {
            let displayMode = LanguageManager.shared.arabicDisplayMode
            switch displayMode {
            case .arabic:
                return arabicText // Арабский текст
            case .englishTranslation:
                return englishTranslation // Английский перевод
            }
        }

        let shouldUseArabic = LanguageManager.shared.shouldUseArabicForDuaLanguage(currentLanguage)
        if shouldUseArabic {
            return arabicText  // Только арабский текст
        } else {
            return translation
        }
    }

    // Get text to insert when selected (for keyboard)
    var insertText: String {
        let currentLanguage = LanguageManager.shared.currentLanguage

        // Для арабского языка проверяем режим отображения
        if currentLanguage == .arabic {
            let displayMode = LanguageManager.shared.arabicDisplayMode
            switch displayMode {
            case .arabic:
                return arabicText // Арабский текст
            case .englishTranslation:
                return englishTranslation // Английский перевод
            }
        }

        let shouldUseArabic = LanguageManager.shared.shouldUseArabicForDuaLanguage(currentLanguage)
        if shouldUseArabic {
            return arabicText  // Только арабский текст
        } else {
            return translation
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
                kazakhTitle: "Табыс тілеу",
                arabicTitle: "تمني النجاح",
                arabicText: "اللهم وفقه لما تحب وترضى",
                englishTranslation: "O Allah, grant him success in what You love and are pleased with",
                russianTranslation: "О Аллах, даруй ему успех в том, что Ты любишь и чем доволен",
                kazakhTranslation: "Уа Аллаһ, оған Сен сүйетін және разы болатын нәрседе табыс бер",
                arabicTranslation: "اللهم وفقه لما تحب وترضى",
                englishUsage: "When wishing someone success in their endeavors",
                russianUsage: "Когда желаете кому-то успеха в делах",
                kazakhUsage: "Біреуге табыс тілегенде",
                arabicUsage: "عند تمني النجاح لشخص ما"
            ),
            Dua(
                key: "health",
                icon: "heart.fill",
                englishTitle: "For Health",
                russianTitle: "За здоровье",
                kazakhTitle: "Денсаулық үшін",
                arabicTitle: "للصحة",
                arabicText: "اللهم اشفه شفاءً لا يغادر سقماً",
                englishTranslation: "O Allah, heal him with a healing that leaves no illness",
                russianTranslation: "О Аллах, исцели его исцелением, после которого не будет болезни",
                kazakhTranslation: "Уа Аллаһ, оны ауру қалдырмайтын шипамен емдеп жазғыр",
                arabicTranslation: "اللهم اشفه شفاءً لا يغادر سقماً",
                englishUsage: "When praying for someone's health and recovery",
                russianUsage: "Когда молитесь за чьё-то здоровье и выздоровление",
                kazakhUsage: "Біреудің денсаулығы мен жазылуы үшін дұға жасағанда",
                arabicUsage: "عند الدعاء لصحة شخص وشفائه"
            ),
            Dua(
                key: "blessing",
                icon: "hands.and.sparkles.fill",
                englishTitle: "For Brother/Sister",
                russianTitle: "За брата/сестру",
                kazakhTitle: "Ағайын үшін",
                arabicTitle: "للأخ/الأخت",
                arabicText: "اللهم بارك له ووفقه",
                englishTranslation: "O Allah, bless him and grant him success",
                russianTranslation: "О Аллах, благослови его и даруй успех",
                kazakhTranslation: "Уа Аллаһ, оған баракат бер және табыс нәсіп ет",
                arabicTranslation: "اللهم بارك له ووفقه",
                englishUsage: "General blessing for a fellow Muslim",
                russianUsage: "Общее благословение для собрата-мусульманина",
                kazakhUsage: "Мұсылман ағайынға жалпы баракат тілеу",
                arabicUsage: "بركة عامة لأخ مسلم"
            ),
            Dua(
                key: "start_task",
                icon: "play.fill",
                englishTitle: "Starting a Task",
                russianTitle: "Начать дело",
                kazakhTitle: "Іс бастау",
                arabicTitle: "بدء المهمة",
                arabicText: "بسم الله توكلت على الله",
                englishTranslation: "In the name of Allah, I place my trust in Allah",
                russianTranslation: "С именем Аллаха, я полагаюсь на Аллаха",
                kazakhTranslation: "Аллаһтың атымен, Аллаһқа сенемін",
                arabicTranslation: "بسم الله توكلت على الله",
                englishUsage: "Before starting any important task or work",
                russianUsage: "Перед началом любого важного дела или работы",
                kazakhUsage: "Кез келген маңызды іс немесе жұмыс бастамас бұрын",
                arabicUsage: "قبل بدء أي مهمة أو عمل مهم"
            ),
            Dua(
                key: "comfort",
                icon: "shield.fill",
                englishTitle: "For Comfort",
                russianTitle: "Успокоить",
                kazakhTitle: "Жұбаныш үшін",
                arabicTitle: "للراحة",
                arabicText: "حسبنا الله ونعم الوكيل",
                englishTranslation: "Allah is sufficient for us, and He is the best Disposer of affairs",
                russianTranslation: "Доволен нам Аллах, и прекрасный Он Покровитель",
                kazakhTranslation: "Бізге Аллаһ жеткілікті, Ол ең жақсы қамқоршы",
                arabicTranslation: "حسبنا الله ونعم الوكيل",
                englishUsage: "In times of difficulty or when seeking Allah's protection",
                russianUsage: "В трудные времена или когда ищете защиты Аллаха",
                kazakhUsage: "Қиын кездерде немесе Аллаһтың қорғауын іздегенде",
                arabicUsage: "في أوقات الصعوبة أو عند طلب حماية الله"
            ),
            Dua(
                key: "travel",
                icon: "car.fill",
                englishTitle: "For Travel",
                russianTitle: "В путь",
                kazakhTitle: "Сапар үшін",
                arabicTitle: "للسفر",
                arabicText: "اللهم إنا نسألك في سفرنا هذا البر والتقوى",
                englishTranslation: "O Allah, we ask You for righteousness and piety in this journey",
                russianTranslation: "О Аллах, даруй нам благочестие в этом пути",
                kazakhTranslation: "Уа Аллаһ, осы сапарымызда бізден тақуалық пен жақсылық сұраймыз",
                arabicTranslation: "اللهم إنا نسألك في سفرنا هذا البر والتقوى",
                englishUsage: "Before starting a journey or travel",
                russianUsage: "Перед началом путешествия или поездки",
                kazakhUsage: "Сапар немесе саяхат бастамас бұрын",
                arabicUsage: "قبل بدء الرحلة أو السفر"
            ),
            Dua(
                key: "forgiveness",
                icon: "square.fill",
                englishTitle: "Seeking Forgiveness",
                russianTitle: "Прощение",
                kazakhTitle: "Кешірім сұрау",
                arabicTitle: "طلب المغفرة",
                arabicText: "أستغفر الله",
                englishTranslation: "I seek forgiveness from Allah",
                russianTranslation: "Прошу прощения у Аллаха",
                kazakhTranslation: "Аллаһтан кешірім сұраймын",
                arabicTranslation: "أستغفر الله",
                englishUsage: "When seeking Allah's forgiveness",
                russianUsage: "Когда просите прощения у Аллаха",
                kazakhUsage: "Аллаһтан кешірім сұрағанда",
                arabicUsage: "عند طلب المغفرة من الله"
            ),
            Dua(
                key: "beauty",
                icon: "sparkles",
                englishTitle: "Admiring Beauty",
                russianTitle: "Красота (МашаАллах)",
                kazakhTitle: "Сұлулықты тамашалау",
                arabicTitle: "الإعجاب بالجمال",
                arabicText: "ما شاء الله لا قوة إلا بالله",
                englishTranslation: "What Allah has willed. There is no power except with Allah",
                russianTranslation: "То, что пожелал Аллах. Нет мощи и силы, кроме как у Аллаха",
                kazakhTranslation: "Аллаһ қалағаны. Аллаһтан басқа күш жоқ",
                arabicTranslation: "ما شاء الله لا قوة إلا بالله",
                englishUsage: "When admiring something beautiful to avoid evil eye",
                russianUsage: "При восхищении чем-то красивым, чтобы избежать сглаза",
                kazakhUsage: "Көз тиюден сақтану үшін әдемі нәрсені тамашалағанда",
                arabicUsage: "عند الإعجاب بشيء جميل لتجنب العين الشريرة"
            ),
            Dua(
                key: "barakah",
                icon: "gift.fill",
                englishTitle: "For Blessing",
                russianTitle: "Баррака",
                kazakhTitle: "Баракат үшін",
                arabicTitle: "للبركة",
                arabicText: "اللهم بارك",
                englishTranslation: "O Allah, grant blessing",
                russianTranslation: "О Аллах, даруй благодать",
                kazakhTranslation: "Уа Аллаһ, баракат бер",
                arabicTranslation: "اللهم بارك",
                englishUsage: "When asking for Allah's blessing on something",
                russianUsage: "Когда просите благословения Аллаха на что-то",
                kazakhUsage: "Бір нәрсеге Аллаһтың баракатын сұрағанда",
                arabicUsage: "عند طلب بركة الله على شيء ما"
            ),
            Dua(
                key: "sisters",
                icon: "person.2.fill",
                englishTitle: "For Sisters",
                russianTitle: "За сестер",
                kazakhTitle: "Апалар үшін",
                arabicTitle: "للأخوات",
                arabicText: "اللهم احفظ أخواتنا",
                englishTranslation: "O Allah, protect our sisters",
                russianTranslation: "О Аллах, оберегай наших сестёр",
                kazakhTranslation: "Уа Аллаһ, апаларымызды қорға",
                arabicTranslation: "اللهم احفظ أخواتنا",
                englishUsage: "When praying for Muslim sisters",
                russianUsage: "Когда молитесь за сестёр-мусульманок",
                kazakhUsage: "Мұсылман апалар үшін дұға жасағанда",
                arabicUsage: "عند الدعاء للأخوات المسلمات"
            ),
            Dua(
                key: "knowledge",
                icon: "book.fill",
                englishTitle: "Before Study",
                russianTitle: "Перед учёбой",
                kazakhTitle: "Оқу алдында",
                arabicTitle: "قبل الدراسة",
                arabicText: "رب زدني علما",
                englishTranslation: "My Lord, increase me in knowledge",
                russianTranslation: "Господи, увеличь мои знания",
                kazakhTranslation: "Раббым, білімімді арттыр",
                arabicTranslation: "رب زدني علما",
                englishUsage: "Before studying or seeking knowledge",
                russianUsage: "Перед учёбой или поиском знаний",
                kazakhUsage: "Оқу немесе білім іздеу алдында",
                arabicUsage: "قبل الدراسة أو طلب العلم"
            ),
            Dua(
                key: "guidance",
                icon: "location.fill",
                englishTitle: "For Guidance",
                russianTitle: "За наставление",
                kazakhTitle: "Бағыт үшін",
                arabicTitle: "للهداية",
                arabicText: "اللهم اهدنا الصراط المستقيم",
                englishTranslation: "O Allah, guide us to the straight path",
                russianTranslation: "О Аллах, веди нас прямым путём",
                kazakhTranslation: "Уа Аллаһ, бізді түзу жолға бағыттай гөр",
                arabicTranslation: "اللهم اهدنا الصراط المستقيم",
                englishUsage: "When seeking Allah's guidance",
                russianUsage: "Когда ищете наставления Аллаха",
                kazakhUsage: "Аллаһтың бағыттауын іздегенде",
                arabicUsage: "عند طلب هداية الله"
            ),
            Dua(
                key: "grief",
                icon: "drop.fill",
                englishTitle: "In Times of Grief",
                russianTitle: "При горе",
                kazakhTitle: "Қайғы кезінде",
                arabicTitle: "في أوقات الحزن",
                arabicText: "إنا لله وإنا إليه راجعون",
                englishTranslation: "Indeed, we belong to Allah and to Him we shall return",
                russianTranslation: "Поистине, мы принадлежим Аллаху и к Нему возвращаемся",
                kazakhTranslation: "Шынында да, біз Аллаһқа тиістіміз және Оған қайтамыз",
                arabicTranslation: "إنا لله وإنا إليه راجعون",
                englishUsage: "In times of loss or difficulty",
                russianUsage: "Во времена потери или трудностей",
                kazakhUsage: "Жоғалту немесе қиындық кезінде",
                arabicUsage: "في أوقات الفقدان أو الصعوبة"
            ),
            Dua(
                key: "night",
                icon: "moon.fill",
                englishTitle: "Good Night",
                russianTitle: "Спокойной ночи",
                kazakhTitle: "Жақсы түн",
                arabicTitle: "ليلة سعيدة",
                arabicText: "باسمك اللهم أموت وأحيا",
                englishTranslation: "In Your name, O Allah, I die and I live",
                russianTranslation: "С Твоим именем, о Аллах, я умираю и живу",
                kazakhTranslation: "Уа Аллаһ, Сенің атыңмен өлемін де тірі боламын",
                arabicTranslation: "باسمك اللهم أموت وأحيا",
                englishUsage: "Before going to sleep",
                russianUsage: "Перед сном",
                kazakhUsage: "Ұйықтамас бұрын",
                arabicUsage: "قبل النوم"
            ),
            Dua(
                key: "morning",
                icon: "sun.max.fill",
                englishTitle: "Morning",
                russianTitle: "Утро",
                kazakhTitle: "Таң",
                arabicTitle: "الصباح",
                arabicText: "اللهم بك أصبحنا وبك أمسينا",
                englishTranslation: "O Allah, with You we begin our morning and with You we end our evening",
                russianTranslation: "С Тобой мы встречаем утро и вечер",
                kazakhTranslation: "Уа Аллаһ, Сенімен таңды және кешті қарсы аламыз",
                arabicTranslation: "اللهم بك أصبحنا وبك أمسينا",
                englishUsage: "Morning remembrance",
                russianUsage: "Утреннее поминание",
                kazakhUsage: "Таңғы зікір",
                arabicUsage: "ذكر الصباح"
            ),
            Dua(
                key: "duaa_protection_blessing",
                icon: "shield.checkered",
                englishTitle: "Protection from Loss",
                russianTitle: "Защита от потерь",
                kazakhTitle: "Жоғалтудан қорғау",
                arabicTitle: "الحماية من الخسارة",
                arabicText: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ",
                englishTranslation: "Allahumma inni a'udhu bika min zawali ni'matika, wa tahawwuli 'afiyatika, wa fuja'ati niqmatika, wa jami'i sakhatika",
                russianTranslation: "Аллахумма инни а'удзу бика мин завали ни'матика, ва тахаввули 'афийатика, ва фуджаати никматика, ва джами'и сахатика",
                kazakhTranslation: "Аллаһумма инни а'узу бика мин завали ни'матика, ва тахаввули 'афийатика, ва фуджаати никматика, ва джами'и сахатика",
                arabicTranslation: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ",
                englishUsage: "When you're afraid of losing blessings, or for protection from Allah's anger and punishment. Good for hard times or expressing concern.",
                russianUsage: "Когда боишься потерять блага, или для защиты от гнева и наказания Аллаха. Подходит для трудных времён или выражения беспокойства.",
                kazakhUsage: "Игіліктерді жоғалтудан қорыққанда немесе Аллаһтың ашуы мен жазасынан қорғану үшін. Қиын кездер үшін немесе алаңдаушылықты білдіру үшін жақсы.",
                arabicUsage: "عندما تخاف من فقدان النعم، أو للحماية من غضب الله وعقابه. جيد للأوقات الصعبة أو التعبير عن القلق."
            ),
            Dua(
                key: "may_allah_return_more",
                icon: "gift.circle.fill",
                englishTitle: "May Allah Reward You",
                russianTitle: "Да воздаст Аллах",
                kazakhTitle: "Аллаһ сізге сауап берсін",
                arabicTitle: "جزاك الله خيراً",
                arabicText: "أَثَابَكَ اللَّهُ",
                englishTranslation: "Athabaka Allahu",
                russianTranslation: "Асабака Аллаху",
                kazakhTranslation: "Асабака Аллаһу",
                arabicTranslation: "أَثَابَكَ اللَّهُ",
                englishUsage: "When someone makes dua for you or does good to you. Islamic way of saying thank you.",
                russianUsage: "Когда кто-то делает дуа за тебя или делает добро. Исламский способ сказать спасибо.",
                kazakhUsage: "Біреу сіз үшін дұға жасағанда немесе сізге жақсылық жасағанда. Рахмет айтудың ислами тәсілі.",
                arabicUsage: "عندما يدعو لك أحد أو يفعل لك خيراً. الطريقة الإسلامية لقول شكراً."
            ),
            Dua(
                key: "duaa_against_evil_eye",
                icon: "eye.slash.fill",
                englishTitle: "Against Evil Eye",
                russianTitle: "От сглаза",
                kazakhTitle: "Көз тиюден",
                arabicTitle: "ضد العين الشريرة",
                arabicText: "اللَّهُمَّ بَارِكْ فِيهِ",
                englishTranslation: "Allahumma barik fihi",
                russianTranslation: "Аллахумма барик фихи",
                kazakhTranslation: "Аллаһумма барик фихи",
                arabicTranslation: "اللَّهُمَّ بَارِكْ فِيهِ",
                englishUsage: "When you fear you might give evil eye, for example when admiring someone.",
                russianUsage: "Когда боишься, что можешь сглазить, например, при восхищении кем-то.",
                kazakhUsage: "Көз тигізуден қорыққанда, мысалы, біреуді тамашалағанда.",
                arabicUsage: "عندما تخاف من أن تصيب بالعين، مثلاً عند الإعجاب بشخص ما."
            ),
            Dua(
                key: "take_care",
                icon: "shield.lefthalf.filled",
                englishTitle: "Take Care",
                russianTitle: "Береги себя",
                kazakhTitle: "Өзіңді сақта",
                arabicTitle: "اعتن بنفسك",
                arabicText: "بِأَمَانِ اللَّهِ",
                englishTranslation: "Bi amaani-llah",
                russianTranslation: "Би амани Ллях",
                kazakhTranslation: "Би амани Ллаһ",
                arabicTranslation: "بِأَمَانِ اللَّهِ",
                englishUsage: "As farewell, wishing safety, especially when traveling.",
                russianUsage: "Как прощание, пожелание безопасности, особенно в пути.",
                kazakhUsage: "Қоштасу кезінде, қауіпсіздік тілеу, әсіресе сапарда.",
                arabicUsage: "كوداع، تمني السلامة، خاصة عند السفر."
            ),
            Dua(
                key: "rain",
                icon: "cloud.rain.fill",
                englishTitle: "Rain Dua",
                russianTitle: "Дуа от дождя",
                kazakhTitle: "Жаңбыр дұғасы",
                arabicTitle: "دعاء المطر",
                arabicText: "اللَّهُمَّ صَيِّبًا نَافِعًا",
                englishTranslation: "Allahumma sayyiban nafi'an",
                russianTranslation: "Аллаахумма сойибэн наафи'а",
                kazakhTranslation: "Аллаһумма сайибан нафиа",
                arabicTranslation: "اللَّهُمَّ صَيِّبًا نَافِعًا",
                englishUsage: "When it rains, recite three times. Asking Allah for beneficial rain.",
                russianUsage: "Во время дождя, читать три раза. Просим у Аллаха полезный дождь.",
                kazakhUsage: "Жаңбыр жауғанда үш рет оқу. Аллаһтан пайдалы жаңбыр сұрау.",
                arabicUsage: "عند المطر، يُقرأ ثلاث مرات. طلب المطر النافع من الله."
            )
        ]
    }
}

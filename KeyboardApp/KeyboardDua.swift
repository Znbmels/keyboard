//
//  KeyboardDua.swift
//  KeyboardApp
//
//  Created by Zainab on 19.06.2025.
//

import Foundation

struct KeyboardDua {
    let id = UUID()
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

    // Convenience initializer for backward compatibility
    init(key: String, icon: String, englishTitle: String, russianTitle: String, arabicText: String,
         englishTranslation: String, russianTranslation: String,
         kazakhTitle: String? = nil, arabicTitle: String? = nil,
         kazakhTranslation: String? = nil, arabicTranslation: String? = nil) {
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
    }

    // Full initializer
    init(key: String, icon: String, englishTitle: String, russianTitle: String, kazakhTitle: String, arabicTitle: String,
         arabicText: String, englishTranslation: String, russianTranslation: String, kazakhTranslation: String, arabicTranslation: String) {
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
    }
    
    // Get title based on current language
    func title(for language: KeyboardLanguage) -> String {
        switch language {
        case .russian:
            return russianTitle
        case .english:
            return englishTitle
        case .kazakh:
            return kazakhTitle
        case .arabic:
            return arabicTitle
        case .french, .german, .chinese, .hindi, .kyrgyz, .uzbek, .korean, .urdu, .spanish, .italian:
            return englishTitle // Fallback to English for new languages
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
    
    // Get display text for keyboard button
    func displayText(for language: KeyboardLanguage) -> String {
        // Для арабского языка проверяем режим отображения
        if language == .arabic {
            let displayMode = KeyboardLanguageManager.shared.arabicDisplayMode
            switch displayMode {
            case .arabic:
                return title(for: language) // Арабский заголовок
            case .englishTranslation:
                return title(for: .english) // Английский заголовок
            }
        }
        return title(for: language)
    }

    // Get text to insert when button is tapped
    func insertText(for language: KeyboardLanguage, useArabic: Bool) -> String {
        if useArabic {
            // Для дуа вставляем арабский текст с переводом
            return "\(arabicText) (\(translation(for: language)))"
        } else {
            // Если арабский не используется, вставляем только перевод
            return translation(for: language)
        }
    }

    // Get text to insert when button is tapped (with dua-specific Arabic preference)
    func insertText(for language: KeyboardLanguage, useArabicForDua: Bool) -> String {
        // Для арабского языка проверяем режим отображения
        if language == .arabic {
            let displayMode = KeyboardLanguageManager.shared.arabicDisplayMode
            switch displayMode {
            case .arabic:
                return arabicText // Только арабский текст
            case .englishTranslation:
                return translation(for: .english) // Английский перевод
            }
        }

        if useArabicForDua {
            // Для дуа вставляем только арабский текст
            return arabicText
        } else {
            // Если арабский не используется, вставляем только перевод
            return translation(for: language)
        }
    }
}

class KeyboardDuaManager {
    static let shared = KeyboardDuaManager()
    
    private let userDefaults: UserDefaults
    private let selectedDuasKey = "keyboard_selected_duas"
    
    var selectedDuas: [KeyboardDua] = []
    
    private init() {
        // Используем App Groups для синхронизации между приложением и клавиатурой
        self.userDefaults = UserDefaults(suiteName: "group.school.nfactorial.muslim.keyboard") ?? UserDefaults.standard
        loadAllDuas()
        refreshData()
    }
    
    private func loadAllDuas() {
        let allDuas = [
            KeyboardDua(
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
                arabicTranslation: "اللهم وفقه لما تحب وترضى"
            ),
            KeyboardDua(
                key: "health",
                icon: "heart.fill",
                englishTitle: "For Health",
                russianTitle: "За здоровье",
                kazakhTitle: "Денсаулық үшін",
                arabicTitle: "للصحة",
                arabicText: "اللهم اشفه شفاءً لا يغادر سقماً",
                englishTranslation: "O Allah, heal him with a healing that leaves no illness",
                russianTranslation: "О Аллах, исцели его исцелением, после которого не будет болезни",
                kazakhTranslation: "Уа Аллаһ, оны ауру қалдырмайтын сауықтырумен сауықтыр",
                arabicTranslation: "اللهم اشفه شفاءً لا يغادر سقماً"
            ),
            KeyboardDua(
                key: "blessing",
                icon: "hands.and.sparkles.fill",
                englishTitle: "For Brother/Sister",
                russianTitle: "За брата/сестру",
                kazakhTitle: "Ағайын-бауырға",
                arabicTitle: "للأخ/الأخت",
                arabicText: "اللهم بارك له ووفقه",
                englishTranslation: "O Allah, bless him and grant him success",
                russianTranslation: "О Аллах, благослови его и даруй успех",
                kazakhTranslation: "Уа Аллаһ, оған баракат бер және табыс бер",
                arabicTranslation: "اللهم بارك له ووفقه"
            ),
            KeyboardDua(
                key: "start_task",
                icon: "play.fill",
                englishTitle: "Starting a Task",
                russianTitle: "Начать дело",
                kazakhTitle: "Іс бастау",
                arabicTitle: "بدء المهمة",
                arabicText: "بسم الله توكلت على الله",
                englishTranslation: "In the name of Allah, I place my trust in Allah",
                russianTranslation: "С именем Аллаха, я полагаюсь на Аллаха",
                kazakhTranslation: "Аллаһтың атымен, мен Аллаһқа сенемін",
                arabicTranslation: "بسم الله توكلت على الله"
            ),
            KeyboardDua(
                key: "comfort",
                icon: "shield.fill",
                englishTitle: "For Comfort",
                russianTitle: "Успокоить",
                kazakhTitle: "Тыныштандыру",
                arabicTitle: "للراحة",
                arabicText: "حسبنا الله ونعم الوكيل",
                englishTranslation: "Allah is sufficient for us, and He is the best Disposer of affairs",
                russianTranslation: "Доволен нам Аллах, и прекрасный Он Покровитель",
                kazakhTranslation: "Бізге Аллаһ жеткілікті, Ол - ең жақсы қамқоршы",
                arabicTranslation: "حسبنا الله ونعم الوكيل"
            ),
            KeyboardDua(
                key: "travel",
                icon: "car.fill",
                englishTitle: "For Travel",
                russianTitle: "В путь",
                kazakhTitle: "Жолға шығу",
                arabicTitle: "للسفر",
                arabicText: "اللهم إنا نسألك في سفرنا هذا البر والتقوى",
                englishTranslation: "O Allah, we ask You for righteousness and piety in this journey",
                russianTranslation: "О Аллах, даруй нам благочестие в этом пути",
                kazakhTranslation: "Уа Аллаһ, осы сапарымызда бізден жақсылық пен тақуаны сұраймыз",
                arabicTranslation: "اللهم إنا نسألك في سفرنا هذا البر والتقوى"
            ),
            KeyboardDua(
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
                arabicTranslation: "أستغفر الله"
            ),
            KeyboardDua(
                key: "beauty",
                icon: "sparkles",
                englishTitle: "Admiring Beauty",
                russianTitle: "Красота (МашаАллах)",
                kazakhTitle: "Сұлулық (МашаАллаһ)",
                arabicTitle: "إعجاب بالجمال",
                arabicText: "ما شاء الله لا قوة إلا بالله",
                englishTranslation: "What Allah has willed. There is no power except with Allah",
                russianTranslation: "То, что пожелал Аллах. Нет мощи и силы, кроме как у Аллаха",
                kazakhTranslation: "Аллаһ қалағаны. Аллаһтан басқа күш жоқ",
                arabicTranslation: "ما شاء الله لا قوة إلا بالله"
            ),
            KeyboardDua(
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
                arabicTranslation: "اللهم بارك"
            ),
            KeyboardDua(
                key: "sisters",
                icon: "person.2.fill",
                englishTitle: "For Sisters",
                russianTitle: "За сестер",
                kazakhTitle: "Ағайын-қарындастарға",
                arabicTitle: "للأخوات",
                arabicText: "اللهم احفظ أخواتنا",
                englishTranslation: "O Allah, protect our sisters",
                russianTranslation: "О Аллах, оберегай наших сестёр",
                kazakhTranslation: "Уа Аллаһ, біздің ағайын-қарындастарымызды қорға",
                arabicTranslation: "اللهم احفظ أخواتنا"
            ),
            KeyboardDua(
                key: "knowledge",
                icon: "book.fill",
                englishTitle: "Before Study",
                russianTitle: "Перед учёбой",
                kazakhTitle: "Оқу алдында",
                arabicTitle: "قبل الدراسة",
                arabicText: "رب زدني علما",
                englishTranslation: "My Lord, increase me in knowledge",
                russianTranslation: "Господи, увеличь мои знания",
                kazakhTranslation: "Раббым, менің білімімді арттыр",
                arabicTranslation: "رب زدني علما"
            ),
            KeyboardDua(
                key: "guidance",
                icon: "location.fill",
                englishTitle: "For Guidance",
                russianTitle: "За наставление",
                kazakhTitle: "Бағыт-бағдар үшін",
                arabicTitle: "للهداية",
                arabicText: "اللهم اهدنا الصراط المستقيم",
                englishTranslation: "O Allah, guide us to the straight path",
                russianTranslation: "О Аллах, веди нас прямым путём",
                kazakhTranslation: "Уа Аллаһ, бізді түзу жолға бағыттай гөр",
                arabicTranslation: "اللهم اهدنا الصراط المستقيم"
            ),
            KeyboardDua(
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
                arabicTranslation: "إنا لله وإنا إليه راجعون"
            ),
            KeyboardDua(
                key: "night",
                icon: "moon.fill",
                englishTitle: "Good Night",
                russianTitle: "Спокойной ночи",
                kazakhTitle: "Жақсы түн",
                arabicTitle: "ليلة سعيدة",
                arabicText: "باسمك اللهم أموت وأحيا",
                englishTranslation: "In Your name, O Allah, I die and I live",
                russianTranslation: "С Твоим именем, о Аллах, я умираю и живу",
                kazakhTranslation: "Сенің атыңмен, уа Аллаһ, мен өлемін және тірі боламын",
                arabicTranslation: "باسمك اللهم أموت وأحيا"
            ),
            KeyboardDua(
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
                arabicTranslation: "اللهم بك أصبحنا وبك أمسينا"
            ),
            KeyboardDua(
                key: "duaa_protection_blessing",
                icon: "shield.checkered",
                englishTitle: "Protection from Loss",
                russianTitle: "Защита от потерь",
                kazakhTitle: "Жоғалтудан қорғау",
                arabicTitle: "الحماية من الخسارة",
                arabicText: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ",
                englishTranslation: "Allahumma inni a'udhu bika min zawali ni'matika, wa tahawwuli 'afiyatika, wa fuja'ati niqmatika, wa jami'i sakhatika",
                russianTranslation: "Аллахумма инни а'удзу бика мин завали ни'матика, ва тахаввули 'афийатика, ва фуджаати никматика, ва джами'и сахатика",
                kazakhTranslation: "Аллахумма инни а'удзу бика мин завали ни'матика, ва тахаввули 'афийатика, ва фуджаати никматика, ва джами'и сахатика",
                arabicTranslation: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ"
            ),
            KeyboardDua(
                key: "may_allah_return_more",
                icon: "gift.circle.fill",
                englishTitle: "May Allah Reward You",
                russianTitle: "Да воздаст Аллах",
                kazakhTitle: "Аллаһ сізге сауап берсін",
                arabicTitle: "جزاك الله خيراً",
                arabicText: "أَثَابَكَ اللَّهُ",
                englishTranslation: "Athabaka Allahu",
                russianTranslation: "Асабака Аллаху",
                kazakhTranslation: "Асабака Аллаху",
                arabicTranslation: "أَثَابَكَ اللَّهُ"
            ),
            KeyboardDua(
                key: "duaa_against_evil_eye",
                icon: "eye.slash.fill",
                englishTitle: "Against Evil Eye",
                russianTitle: "От сглаза",
                kazakhTitle: "Көз тигуден",
                arabicTitle: "ضد العين الحاسدة",
                arabicText: "اللَّهُمَّ بَارِكْ فِيهِ",
                englishTranslation: "Allahumma barik fihi",
                russianTranslation: "Аллахумма барик фихи",
                kazakhTranslation: "Аллахумма барик фихи",
                arabicTranslation: "اللَّهُمَّ بَارِكْ فِيهِ"
            ),
            KeyboardDua(
                key: "take_care",
                icon: "shield.lefthalf.filled",
                englishTitle: "Take Care",
                russianTitle: "Береги себя",
                kazakhTitle: "Өзіңді сақта",
                arabicTitle: "اعتن بنفسك",
                arabicText: "بِأَمَانِ اللَّهِ",
                englishTranslation: "Bi amaani-llah",
                russianTranslation: "Би амани Ллях",
                kazakhTranslation: "Би амани Ллях",
                arabicTranslation: "بِأَمَانِ اللَّهِ"
            ),
            KeyboardDua(
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
                arabicTranslation: "اللَّهُمَّ صَيِّبًا نَافِعًا"
            )
        ]
        
        // Сохраняем все дуа для использования
        self.allDuas = allDuas
    }
    
    private var allDuas: [KeyboardDua] = []
    
    func refreshData() {
        if let data = userDefaults.data(forKey: selectedDuasKey),
           let selectedKeys = try? JSONDecoder().decode([String].self, from: data) {
            selectedDuas = allDuas.filter { selectedKeys.contains($0.key) }
            print("🔄 KeyboardDuaManager: Loaded \(selectedDuas.count) selected duas: \(selectedKeys)")
        } else {
            // По умолчанию выбираем первые 5 дуа
            selectedDuas = Array(allDuas.prefix(5))
            print("🔄 KeyboardDuaManager: Using default \(selectedDuas.count) duas")
        }
    }
}

//
//  Constants.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import Foundation

struct AppConstants {
    // MARK: - Onboarding Content
    struct Onboarding {
        static let page1Title = "onboarding_page1_title"
        static let page1Description = "onboarding_page1_description"
        static let page1Icon = "book.quran"

        static let page2Title = "onboarding_page2_title"
        static let page2Description = "onboarding_page2_description"
        static let page2Icon = "brain.head.profile"

        static let page3Title = "onboarding_page3_title"
        static let page3Description = "onboarding_page3_description"
        static let page3Icon = "checkmark.circle.fill"
    }

    // MARK: - Button Texts
    struct ButtonTexts {
        static let addKeyboard = "button_add_keyboard"
        static let getStarted = "button_get_started"
        static let next = "button_next"
        static let done = "button_done"
        static let skip = "button_skip"
    }

    // MARK: - Font Names
    struct Fonts {
        static let amiriQuranRegular = "AmiriQuran-Regular"
        static let amiriQuranBold = "AmiriQuran-Bold"
    }

    // MARK: - Animation Durations
    struct Animation {
        static let defaultDuration: Double = 0.3
        static let pageTransition: Double = 0.4
    }
}

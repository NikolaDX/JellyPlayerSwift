//
//  LanguageService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/4/25.
//

import Foundation

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case arabic = "ar"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh_Hant"
    case french = "fr"
    case german = "de"
    case hindi = "hi"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"
    case portuguese = "pt-PT"
    case russian = "ru"
    case serbian = "sr"
    case spanish = "es"
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .english:
            return String(localized: "English", locale: Locale(identifier: "en"))
        case .arabic:
            return String(localized: "Arabic", locale: Locale(identifier: "ar"))
        case .chineseSimplified:
            return String(localized: "Chinese (Simplified)", locale: Locale(identifier: "zh-Hans"))
        case .chineseTraditional:
            return String(localized: "Chinese (Traditional)", locale: Locale(identifier: "zh-Hant"))
        case .french:
            return String(localized: "French", locale: Locale(identifier: "fr"))
        case .german:
            return String(localized: "German", locale: Locale(identifier: "de"))
        case .hindi:
            return String(localized: "Hindi", locale: Locale(identifier: "hi"))
        case .italian:
            return String(localized: "Italian", locale: Locale(identifier: "it"))
        case .japanese:
            return String(localized: "Japanese", locale: Locale(identifier: "ja"))
        case .korean:
            return String(localized: "Korean", locale: Locale(identifier: "ko"))
        case .portuguese:
            return String(localized: "Portuguese", locale: Locale(identifier: "pt-PT"))
        case .russian:
            return String(localized: "Russian", locale: Locale(identifier: "ru"))
        case .serbian:
            return String(localized: "Serbian", locale: Locale(identifier: "sr"))
        case .spanish:
            return String(localized: "Spanish", locale: Locale(identifier: "es"))
        }
    }
}


class LanguageService: ObservableObject {
    @Published var selectedLanguage: Language {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: languageKey)
        }
    }
    
    init() {
        let rawValue = UserDefaults.standard.string(forKey: languageKey) ?? Language.english.rawValue
        selectedLanguage = Language(rawValue: rawValue) ?? .english
    }
}

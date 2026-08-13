//
//  TimeOfDay.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 22. 7. 2026..
//

import Foundation

enum TimeOfDay: String, Codable {
    case morning
    case noon
    case afternoon
    case evening
    case night
    
    init(hour: Int) {
        switch hour {
        case 5..<12:
            self = .morning
        case 12..<18:
            self = .afternoon
        case 18..<21:
            self = .evening
        case 21..<24, 0..<5:
            self = .night
        default:
            self = .afternoon
        }
    }
}

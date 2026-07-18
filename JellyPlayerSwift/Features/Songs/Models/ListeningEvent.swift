//
//  ListeningEvent.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 8. 7. 2026..
//

import Foundation

struct ListeningEvent: Codable {
    let songId: String
    let hourOfDay: Int
    let percentListened: Double
    let playCount: Int
    let isFavorite: Bool
    let artists: String
    let latitude: Double
    let longitude: Double
    
    var calculatedAffinity: Double {
        let completionScore = percentListened * 3.5
        let favoriteScore = isFavorite ? 1.5 : 0.0
        let fatiguePenalty = playCount > 10 ? 0.6 : 0.0
        return max(0.0, min(completionScore + favoriteScore - fatiguePenalty, 5.0))
    }
}

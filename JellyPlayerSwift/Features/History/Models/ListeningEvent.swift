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
    let latitude: Double
    let longitude: Double
    let activity: UserActivity
    let audioOutput: AudioOutput
    let audioVolume: Float
    
    enum CodingKeys: String, CodingKey {
        case songId
        case hourOfDay
        case percentListened
        case playCount
        case isFavorite
        case latitude
        case longitude
        case activity
        case audioOutput
        case audioVolume
    }
    
    init(
        songId: String,
        hourOfDay: Int,
        percentListened: Double,
        playCount: Int,
        isFavorite: Bool,
        latitude: Double,
        longitude: Double,
        activity: UserActivity,
        audioOutput: AudioOutput,
        audioVolume: Float
    ) {
        self.songId = songId
        self.hourOfDay = hourOfDay
        self.percentListened = percentListened
        self.playCount = playCount
        self.isFavorite = isFavorite
        self.latitude = latitude
        self.longitude = longitude
        self.activity = activity
        self.audioOutput = audioOutput
        self.audioVolume = audioVolume
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        songId = try container.decode(String.self, forKey: .songId)
        hourOfDay = try container.decode(Int.self, forKey: .hourOfDay)
        percentListened = try container.decode(Double.self, forKey: .percentListened)
        playCount = try container.decode(Int.self, forKey: .playCount)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        activity = try container.decode(UserActivity.self, forKey: .activity)
        audioOutput = try container.decode(AudioOutput.self, forKey: .audioOutput)
        audioVolume = try container.decode(Float.self, forKey: .audioVolume)
    }
    
    var calculatedAffinity: Double {
        let completionScore = percentListened * 3.5
        let favoriteScore = isFavorite ? 1.5 : 0.0
        let fatiguePenalty = playCount > 10 ? 0.6 : 0.0
        return max(0.0, min(completionScore + favoriteScore - fatiguePenalty, 5.0))
    }
}

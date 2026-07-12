//
//  RecommenderFeatures.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 12. 7. 2026..
//

import Foundation
import TabularData

enum RecommenderFeatures {
    static let featureColumns = ["hourOfDay", "playCount", "isFavorite", "artists"]
    static let targetColumn = "calculatedAffinity"
    
    static func dataFrame(from history: [ListeningEvent]) -> DataFrame {
        var df = DataFrame()
        df.append(column: Column(name: "hourOfDay", contents: history.map { $0.hourOfDay }))
        df.append(column: Column(name: "playCount", contents: history.map { Double($0.playCount) }))
        df.append(column: Column(name: "isFavorite", contents: history.map { $0.isFavorite ? 1.0 : 0.0 }))
        df.append(column: Column(name: targetColumn, contents: history.map { $0.calculatedAffinity }))
        df.append(column: Column(name: "artists", contents: history.map { $0.artists }))
        return df
    }
    
    static func inputDictionary(for song: Song, currentHour: Int) -> [String: Any] {
        [
            "artists": song.Artists.joined(separator: ", "),
            "hourOfDay": Double(currentHour),
            "playCount": Double(song.UserData.PlayCount),
            "isFavorite": song.UserData.IsFavorite ? 1.0 : 0.0
        ]
    }
}

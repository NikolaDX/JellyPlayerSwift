//
//  RecommenderFeatures.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 12. 7. 2026..
//

import Foundation
import TabularData

enum RecommenderFeatures {
    static let featureColumns = [
        "hourOfDay",
        "playCount",
        "isFavorite",
        "latitude",
        "longitude",
        "activity",
        "audioOutput",
        "audioVolume",
        "timeOfDay",
        "networkType",
        "dayOfWeek",
        "energy",
        "duration"
    ]
    
    static let targetColumn = "calculatedAffinity"
    
    static func dataFrame(from history: [ListeningEvent]) -> DataFrame {
        var df = DataFrame()
        df.append(column: Column(name: "hourOfDay", contents: history.map { $0.hourOfDay }))
        df.append(column: Column(name: "playCount", contents: history.map { Double($0.playCount) }))
        df.append(column: Column(name: "isFavorite", contents: history.map { $0.isFavorite ? 1.0 : 0.0 }))
        df.append(column: Column(name: targetColumn, contents: history.map { $0.calculatedAffinity }))
        df.append(column: Column(name: "latitude", contents: history.map { $0.latitude }))
        df.append(column: Column(name: "longitude", contents: history.map { $0.longitude }))
        df.append(column: Column(name: "activity", contents: history.map { $0.activity.rawValue }))
        df.append(column: Column(name: "audioOutput", contents: history.map { $0.audioOutput.rawValue }))
        df.append(column: Column(name: "audioVolume", contents: history.map { $0.audioVolume }))
        df.append(column: Column(name: "timeOfDay", contents: history.map { $0.timeOfDay.rawValue }))
        df.append(column: Column(name: "networkType", contents: history.map { $0.networkType.rawValue }))
        df.append(column: Column(name: "dayOfWeek", contents: history.map { $0.dayOfWeek }))
        df.append(column: Column(name: "energy", contents: history.map { $0.energy }))
        df.append(column: Column(name: "duration", contents: history.map { $0.duration }))
        return df
    }
    
    static func inputDictionary(
        for song: Song,
        currentHour: Int,
        latitude: Double,
        longitude: Double,
        activity: String,
        audioOutput: AudioOutput,
        audioVolume: Float,
        timeOfDay: TimeOfDay,
        networkType: NetworkType,
        dayOfWeek: Int,
        energy: Double,
        duration: Int
    ) -> [String: Any] {
        [
            "artists": song.Artists.joined(separator: ", "),
            "hourOfDay": Double(currentHour),
            "playCount": Double(song.UserData.PlayCount),
            "isFavorite": song.UserData.IsFavorite ? 1.0 : 0.0,
            "latitude": latitude,
            "longitude": longitude,
            "activity": activity,
            "audioOutput": audioOutput.rawValue,
            "audioVolume": audioVolume,
            "timeOfDay": timeOfDay.rawValue,
            "networkType": networkType.rawValue,
            "dayOfWeek": dayOfWeek,
            "energy": energy,
            "duration": duration
        ]
    }
}

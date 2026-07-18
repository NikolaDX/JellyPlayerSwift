//
//  HistoryService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 8. 7. 2026..
//

import Foundation

class HistoryService {
    static let shared = HistoryService()
    
    private var historyURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("listening_history.json")
    }
    
    private let queue = DispatchQueue(label: "com.jellyplayer.historyqueue", attributes: .concurrent)
    
    private init() {}
    
    func logEvent(for song: Song) {
        queue.async(flags: .barrier) {
            var currentHistory = self.fetchLocalHistoryInternal()
            let currentHour = Calendar.current.component(.hour, from: Date())
            
            let currentTime = PlaybackService.shared.currentTime
            let totalDuration = PlaybackService.shared.duration
            
            let ratio = totalDuration > 0 ? min(currentTime / totalDuration, 1.0) : 1.0
            
            var latitude = 0.0
            var longitude = 0.0
            
            LocationService.shared.requestLocation()
            
            if let location = LocationService.shared.location {
                latitude = location.latitude
                longitude = location.longitude
            }
            
            let newEvent = ListeningEvent(
                songId: song.Id,
                hourOfDay: currentHour,
                percentListened: ratio,
                playCount: song.UserData.PlayCount + 1,
                isFavorite: song.UserData.IsFavorite,
                artists: song.Artists.joined(separator: ", "),
                latitude: latitude,
                longitude: longitude
            )
            
            currentHistory.append(newEvent)
            
            if currentHistory.count > 1500 {
                currentHistory.removeFirst(currentHistory.count - 1500)
            }
            
            do {
                let data = try JSONEncoder().encode(currentHistory)
                try data.write(to: self.historyURL, options: .atomic)
                print("Interaction saved to local storage for: \(song.Name)")
            } catch {
                print("Failed to write listening interaction data: \(error)")
            }
        }
    }
    
    func fetchLocalHistory() -> [ListeningEvent] {
        queue.sync {
            return fetchLocalHistoryInternal()
        }
    }
    
    func fetchLocalHistoryInternal() -> [ListeningEvent] {
        guard FileManager.default.fileExists(atPath: historyURL.path) else { return [] }
        
        do {
            let data = try Data(contentsOf: historyURL)
            return try JSONDecoder().decode([ListeningEvent].self, from: data)
        } catch {
            print("Erorr reading local history contents: \(error)")
            return []
        }
    }
}

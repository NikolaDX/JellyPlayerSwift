//
//  HistoryService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 8. 7. 2026..
//

import AVFAudio
import Foundation

class HistoryService {
    static let shared = HistoryService()
    
    private var historyURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("listening_history.json")
    }
    
    private let queue = DispatchQueue(label: "com.jellyplayer.historyqueue", attributes: .concurrent)
    
    private let maxHistoryEntries = 1500
    
    private init() {}
    
    func logEvent(for song: Song) {
        queue.async(flags: .barrier) {
            var currentHistory = self.fetchLocalHistoryInternal()
            let currentHour = Calendar.current.component(.hour, from: Date())
            
            let currentTime = PlaybackService.shared.currentTime
            
            let totalDuration = PlaybackService.shared.duration
            
            let ratio = totalDuration > 0 ? min(currentTime / totalDuration, 1.0) : 1.0
            
            let latitude = LocationService.shared.location?.latitude ?? 0
            let longitude = LocationService.shared.location?.longitude ?? 0
            
            let audioOutput = AudioContextService.shared.output
            let audioVolume = AudioContextService.shared.volume
            
            var networkType: NetworkType = .offline
            
            if !NetworkService.shared.isConnected {
                networkType = .offline
            } else if NetworkService.shared.usesWifi {
                networkType = .wifi
            } else {
                networkType = .cellular
            }
            
            let energy = AudioAnalysisService.shared.getEnergy(for: song.Id) ?? 0.2
            
            let newEvent = ListeningEvent(
                songId: song.Id,
                hourOfDay: currentHour,
                percentListened: ratio,
                playCount: song.UserData.PlayCount + 1,
                isFavorite: song.UserData.IsFavorite,
                latitude: latitude,
                longitude: longitude,
                activity: MotionService.shared.activity,
                audioOutput: audioOutput,
                audioVolume: audioVolume,
                timeOfDay: TimeOfDay(hour: currentHour),
                networkType: networkType,
                dayOfWeek: Calendar.current.component(.weekday, from: Date()),
                energy: energy,
                duration: song.durationInSeconds
            )
            
            currentHistory.append(newEvent)
            
            if currentHistory.count > self.maxHistoryEntries {
                currentHistory.removeFirst(currentHistory.count - self.maxHistoryEntries)
            }
            
            do {
                let data = try JSONEncoder().encode(currentHistory)
                
                if let json = String(data: data, encoding: .utf8) {
                    print("Current history:")
                    print(json)
                }
                
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

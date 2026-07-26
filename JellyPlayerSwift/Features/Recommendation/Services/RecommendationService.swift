//
//  RecommendationService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 8. 7. 2026..
//

import AVFAudio
import CoreML
import Foundation

class RecommendationService {
    static let shared = RecommendationService()
    var personalizedModel: MLModel?
    
    private var modelURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("UserPersonalizedRecommender.mlmodelc")
    }
    
    private init() {
        loadModel()
        NotificationCenter.default.addObserver(self, selector: #selector(loadModel), name: NSNotification.Name("ModelDidUpdate"), object: nil)
    }
    
    @objc func loadModel() {
        do {
            self.personalizedModel = try MLModel(contentsOf: modelURL)
            print("Loaded personalized model.")
        } catch {
            print("No personalized model found yet. User needs to generate more data.")
        }
    }
    
    func score(toScore songs: [Song], request: RecommendationRequest) -> [(song: Song, score: Double)] {
        guard let model = personalizedModel else {
            return []
        }
        
        let currentDate = Date()
        
        let currentHour = Calendar.current.component(.hour, from: currentDate)
        
        let latitude = LocationService.shared.location?.latitude ?? 0.0
        let longitude = LocationService.shared.location?.longitude ?? 0.0
        
        var scoredSongs: [(song: Song, score: Double)] = []
        
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
        
        for song in songs {
            let energy = AudioAnalysisService.shared.getEnergy(for: song.Id) ?? 0.2
            
            let input = RecommenderFeatures.inputDictionary(
                for: song,
                currentHour: currentHour,
                latitude: latitude,
                longitude: longitude,
                activity: MotionService.shared.activity.rawValue,
                audioOutput: audioOutput,
                audioVolume: audioVolume,
                timeOfDay: TimeOfDay(hour: currentHour),
                networkType: networkType,
                dayOfWeek: Calendar.current.component(.weekday, from: currentDate),
                energy: energy,
                duration: song.durationInSeconds
            )
            
            var score = -Double.infinity
            
            do {
                let provider = try MLDictionaryFeatureProvider(dictionary: input)
                let prediction = try model.prediction(from: provider)
                score = prediction
                    .featureValue(for: RecommenderFeatures.targetColumn)?
                    .doubleValue ?? -Double.infinity
            } catch {
                print(error)
            }
            
            if (networkType == .cellular) {
                if DownloadService.shared.downloads.contains(song) {
                    score += 5.0
                }
            }
            
            switch request {
            case .regular:
                break
            case .queue(let queue):
                if queue.contains(song) {
                    score = -.infinity
                }
                
                if let genres = song.Genres,
                   let lastGenres = queue.last?.Genres
                {
                    if !Set(genres).intersection(lastGenres).isEmpty {
                        score += 5.0
                    }
                }
                
                if song.UserData.IsFavorite {
                    score += 1.0
                }
                
                if song.Id == queue.last?.Id {
                    score = -.infinity
                }
            case .shuffle(let currentSong):
                if song.UserData.IsFavorite {
                    score += 1.0
                }
                
                if let genres = song.Genres,
                   let currentGenres = currentSong.Genres
                {
                    if !Set(genres).intersection(currentGenres).isEmpty {
                        score += 1.0
                    }
                }
                
                score += Double.random(in: -1.0...1.0)
            }
            
            scoredSongs.append((song, score))
        }
        
        return scoredSongs
    }
    
    func getRecommendations(from availableSongs: [Song], request: RecommendationRequest) -> [Song] {
        guard personalizedModel != nil else {
            return availableSongs
        }
        
        return score(
            toScore: availableSongs,
            request: request
        )
            .sorted(by: { $0.score > $1.score })
            .map(\.song)
    }
    
    func smartShuffle(songs: [Song], currentSong: Song?) -> [Song] {
        getRecommendations(from: songs, request: .shuffle(currentSong: currentSong ?? songs[0]))
    }
}

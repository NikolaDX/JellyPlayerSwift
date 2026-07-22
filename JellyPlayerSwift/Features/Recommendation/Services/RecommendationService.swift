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
    
    func score(toScore songs: [Song], currentHour: Int, request: RecommendationRequest) -> [(song: Song, score: Double)] {
        guard let model = personalizedModel else {
            return []
        }
        
        let latitude = LocationService.shared.location?.latitude ?? 0.0
        let longitude = LocationService.shared.location?.longitude ?? 0.0
        
        var scoredSongs: [(song: Song, score: Double)] = []
        
        let audioOutput = AudioContextService.shared.output
        let audioVolume = AudioContextService.shared.volume
        
        for song in songs {
            let input = RecommenderFeatures.inputDictionary(
                for: song,
                currentHour: currentHour,
                latitude: latitude,
                longitude: longitude,
                activity: MotionService.shared.activity.rawValue,
                audioOutput: audioOutput,
                audioVolume: audioVolume
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
            
            score += song.UserData.PlayCount == 0 ? 1.0 : song.UserData.PlayCount <= 3 ? 0.7 : 0
            
            switch request {
            case .home:
                break
            case .queue(let currentSong, let queue):
                if queue.contains(song) {
                    score = -.infinity
                }
                
                if Set(song.Artists)
                    .intersection(currentSong.Artists)
                    .isEmpty == false {
                    score += 0.5
                }
                
                if song.AlbumId == currentSong.AlbumId {
                    score += 0.3
                }
                
                if song.UserData.IsFavorite {
                    score += 0.2
                }
                
                if song.Id == currentSong.Id {
                    score = -.infinity
                }
            }
            
            scoredSongs.append((song, score))
        }
        
        return scoredSongs
    }
    
    func getRecommendations(from availableSongs: [Song], currentHour: Int, request: RecommendationRequest) -> [Song] {
        score(
            toScore: availableSongs,
            currentHour: currentHour,
            request: request
        )
            .sorted(by: { $0.score > $1.score })
            .map(\.song)
    }
}

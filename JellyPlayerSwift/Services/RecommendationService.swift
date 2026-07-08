//
//  RecommendationService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 8. 7. 2026..
//

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
    
    func getRecommendations(from availableSongs: [Song], currentHour: Int) -> [Song] {
        guard let model = personalizedModel else {
            return []
        }
        
        var scoredSongs: [(song: Song, score: Double)] = []
        
        for song in availableSongs {
            do {
                let songArtists = song.Artists.joined(separator: ", ")
                
                let inputFeatures: [String: Any] = [
                    "artists": songArtists,
                    "hourOfDay": Double(currentHour),
                    "playCount": Double(song.UserData.PlayCount),
                    "isFavorite": song.UserData.IsFavorite ? 1.0 : 0.0
                ]
                
                let provider = try MLDictionaryFeatureProvider(dictionary: inputFeatures)
                let prediction = try model.prediction(from: provider)
                
                if var score = prediction.featureValue(for: "calculatedAffinity")?.doubleValue {
                    if song.UserData.PlayCount == 0 {
                        score += 1.0
                    } else if song.UserData.PlayCount <= 3 {
                        score += 0.7
                    }
                    
                    scoredSongs.append((song: song, score: score))
                }
            } catch {
                print("Prediction error: \(error)")
            }
        }
        
        return scoredSongs.sorted { $0.score > $1.score }.map { $0.song }
    }
}

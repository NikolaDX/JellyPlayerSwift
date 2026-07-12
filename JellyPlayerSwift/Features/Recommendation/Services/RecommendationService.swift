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
            let inputFeatures = RecommenderFeatures.inputDictionary(for: song, currentHour: currentHour)
            
            var estimatedScore: Double? = nil
                        
            do {
                let provider = try MLDictionaryFeatureProvider(dictionary: inputFeatures)
                let prediction = try model.prediction(from: provider)
                
                estimatedScore = prediction.featureValue(for: RecommenderFeatures.targetColumn)?.doubleValue
            } catch {
                estimatedScore = nil
            }
            
            let playCountBoost: Double = song.UserData.PlayCount == 0 ? 1.0 : song.UserData.PlayCount <= 3 ? 0.7 : 0.0
            
            scoredSongs.append((song: song, score: (estimatedScore ?? -Double.infinity) + playCountBoost))
        }
        
        return scoredSongs.sorted { $0.score > $1.score }.map { $0.song }
    }
}

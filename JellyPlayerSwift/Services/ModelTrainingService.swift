//
//  ModelTrainingService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 8. 7. 2026..
//

import Foundation
import CreateML
import CoreML
import TabularData

class ModelTrainingService {
    static let shared = ModelTrainingService()
        
    private init() {}
    
    private var uncompiledModelURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("UserPersonalizedRecommender.mlmodel")
    }
    
    private var compiledModelURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("UserPersonalizedRecommender.mlmodelc")
    }
    
    func trainModel(with history: [ListeningEvent]) async {
        guard history.count > 10 else {
            print("Not enough data to train yet. Keep listening!")
            return
        }
        
        let hours = history.map { $0.hourOfDay }
        let playCounts = history.map { Double($0.playCount) }
        let favorites = history.map { $0.isFavorite ? 1.0 : 0.0 }
        let affinities = history.map { $0.calculatedAffinity }
        let artists = history.map { $0.artists }
        
        do {
            var dataFrame = DataFrame()
            
            dataFrame.append(column: Column(name: "hourOfDay", contents: hours))
            dataFrame.append(column: Column(name: "playCount", contents: playCounts))
            dataFrame.append(column: Column(name: "isFavorite", contents: favorites))
            dataFrame.append(column: Column(name: "calculatedAffinity", contents: affinities))
            dataFrame.append(column: Column(name: "artists", contents: artists))
            
            print("Starting on-device training...")
            
            let regressor = try MLLinearRegressor(trainingData: dataFrame, targetColumn: "calculatedAffinity")
            let metadata = MLModelMetadata(author: "JellyPlayer", shortDescription: "Personalized Model", version: "1.0")
            
            try regressor.write(to: uncompiledModelURL, metadata: metadata)
            
            print("Compiling model on-device...")
            let temporaryCompiledURL = try await MLModel.compileModel(at: uncompiledModelURL)
            
            if FileManager.default.fileExists(atPath: compiledModelURL.path) {
                try FileManager.default.removeItem(at: compiledModelURL)
            }
            
            try FileManager.default.moveItem(at: temporaryCompiledURL, to: compiledModelURL)
            
            try? FileManager.default.removeItem(at: uncompiledModelURL)
            
            print("Successfully trained, compiled, and saved personalized model!")
            
            NotificationCenter.default.post(name: NSNotification.Name("ModelDidUpdate"), object: nil)
        } catch {
            print("Failed to train model on device: \(error)")
        }
    }
    
}

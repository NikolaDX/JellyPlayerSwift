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
    
    func trainModel(with history: [ListeningEvent], using algorithm: RegressorAlgorithm = .linear) async {
        guard history.count > 10 else {
            print("Not enough data to train yet. Keep listening!")
            return
        }
        do {
            let dataFrame = RecommenderFeatures.dataFrame(from: history)
            let metadata = MLModelMetadata(author: "JellyPlayer", shortDescription: "Personalized Model", version: "1.0")

            try algorithm.train(
                trainingData: dataFrame,
                targetColumn: RecommenderFeatures.targetColumn,
                to: uncompiledModelURL,
                metadata: metadata
            )

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

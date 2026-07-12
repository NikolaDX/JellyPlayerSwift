//
//  ModelEvaluationService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 12. 7. 2026..
//

import CreateML
import Foundation
import TabularData

class ModelEvaluationService {
    static let shared = ModelEvaluationService()
    
    func compareAlgorithms(history: [ListeningEvent]) -> [ModelEvaluationResult] {
        guard history.count > 20 else {
            print("Need more data before comparing models.")
            return []
        }
        
        let fullData = RecommenderFeatures.dataFrame(from: history)
        let (trainingSlice, testSlice) = fullData.randomSplit(by: 0.8, seed: 42)
        let trainingData = DataFrame(trainingSlice)
        let testData = DataFrame(testSlice)
        
        var results: [ModelEvaluationResult] = []
        
        for algorithm in RegressorAlgorithm.allCases {
            let start = Date()
            do {
                switch algorithm {
                case .linear:
                    let m = try MLLinearRegressor(trainingData: trainingData, targetColumn: RecommenderFeatures.targetColumn)
                    let metrics = m.evaluation(on: testData)
                    results.append(.init(algorithm: algorithm, rmse: metrics.rootMeanSquaredError, trainingTime: Date().timeIntervalSince(start)))
                case .decisionTree:
                    let m = try MLDecisionTreeRegressor(trainingData: trainingData, targetColumn: RecommenderFeatures.targetColumn)
                    let metrics = m.evaluation(on: testData)
                    results.append(.init(algorithm: algorithm, rmse: metrics.rootMeanSquaredError, trainingTime: Date().timeIntervalSince(start)))
                case .boostedTree:
                    let m = try MLBoostedTreeRegressor(trainingData: trainingData, targetColumn: RecommenderFeatures.targetColumn)
                    let metrics = m.evaluation(on: testData)
                    results.append(.init(algorithm: algorithm, rmse: metrics.rootMeanSquaredError, trainingTime: Date().timeIntervalSince(start)))
                case .randomForest:
                    let m = try MLRandomForestRegressor(trainingData: trainingData, targetColumn: RecommenderFeatures.targetColumn)
                    let metrics = m.evaluation(on: testData)
                    results.append(.init(algorithm: algorithm, rmse: metrics.rootMeanSquaredError, trainingTime: Date().timeIntervalSince(start)))
                }
            } catch {
                print("\(algorithm.displayName) failed: \(error)")
            }
        }
        
        printComparisonTable(results)
        return results
    }
    
    private func printComparisonTable(_ results: [ModelEvaluationResult]) {
        print("Models:\n")
        for r in results.sorted(by: { $0.rmse < $1.rmse }) {
            print("Name: \(r.algorithm.displayName)")
            print("Training time: \(r.trainingTime)")
            print("Root mean square error: \(r.rmse)")
            print("")
        }
        print("")
    }
}

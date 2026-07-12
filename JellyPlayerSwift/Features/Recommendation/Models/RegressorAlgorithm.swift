//
//  RegressorAlgorithm.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 12. 7. 2026..
//

import CreateML
import CoreML
import Foundation
import TabularData

enum RegressorAlgorithm: String, CaseIterable, Identifiable {
    case linear
    case decisionTree
    case boostedTree
    case randomForest
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .linear:
            return "Linear Regression"
        case .decisionTree:
            return "Decision Tree"
        case .boostedTree:
            return "Boosted Tree"
        case .randomForest:
            return "Random Forest"
        }
    }
    
    func train(trainingData: DataFrame, targetColumn: String, to url: URL, metadata: MLModelMetadata) throws {
        switch self {
        case .linear:
            let m = try MLLinearRegressor(trainingData: trainingData, targetColumn: targetColumn)
            try m.write(to: url, metadata: metadata)
        case .decisionTree:
            let m = try MLDecisionTreeRegressor(trainingData: trainingData, targetColumn: targetColumn)
            try m.write(to: url, metadata: metadata)
        case .boostedTree:
            let m = try MLBoostedTreeRegressor(trainingData: trainingData, targetColumn: targetColumn)
            try m.write(to: url, metadata: metadata)
        case .randomForest:
            let m = try MLRandomForestRegressor(trainingData: trainingData, targetColumn: targetColumn)
            try m.write(to: url, metadata: metadata)
        }
    }
}

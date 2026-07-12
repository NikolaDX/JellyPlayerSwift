//
//  ModelEvaluationResult.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 12. 7. 2026..
//

import Foundation

struct ModelEvaluationResult {
    let algorithm: RegressorAlgorithm
    let rmse: Double
    let trainingTime: TimeInterval
}

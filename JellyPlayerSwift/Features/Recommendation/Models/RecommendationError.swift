//
//  RecommendationError.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 1. 8. 2026..
//

import Foundation

enum RecommendationError: LocalizedError {
    case modelUnavailable
    case recommendationFailed
    
    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Your recommendation model isn't available yet. Listen to a few more songs until a model is trained."
        case .recommendationFailed:
            return "Recommendations couldn't be generated."
        }
    }
}

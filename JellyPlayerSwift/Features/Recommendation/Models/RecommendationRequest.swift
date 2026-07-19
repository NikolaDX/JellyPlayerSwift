//
//  RecommendationRequest.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 18. 7. 2026..
//

import Foundation

enum RecommendationRequest {
    case home
    case queue(currentSong: Song, queue: [Song])
}


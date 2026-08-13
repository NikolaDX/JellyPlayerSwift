//
//  RecommendationRequest.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 18. 7. 2026..
//

import Foundation

enum RecommendationRequest {
    case regular
    case queue(queue: [Song])
    case shuffle(currentSong: Song)
    case playlist(playlistSongs: [Song])
}


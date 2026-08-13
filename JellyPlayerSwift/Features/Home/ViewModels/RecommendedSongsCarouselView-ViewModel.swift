//
//  RecommendedSongsCarouselView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 3. 8. 2026..
//

import Foundation

extension RecommendedSongsCarouselView {
    @Observable
    class ViewModel {
        var recommendedSongs: [Song] = []
        var isLoading = false
        
        var lastFetched: Date?
        let cacheLifetime: TimeInterval = 300
        let fetchLimit: Int = 51
        
        func loadMLRecommendations(forceRefresh: Bool = false) async {
            if !forceRefresh,
                let lastFetched,
                Date().timeIntervalSince(lastFetched) < cacheLifetime,
                !recommendedSongs.isEmpty {
                return
            }
            
            isLoading = true
            
            do {
                let allSongs = await SongsService().fetchAllSongs()
                let modelResults = try RecommendationService.shared.getRecommendations(from: allSongs, request: RecommendationRequest.regular)
                self.recommendedSongs = Array(modelResults.prefix(fetchLimit))
                self.lastFetched = Date()
            } catch {
                print("Error generating recommendations: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
}

//
//  FavoritesView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

extension FavoritesView {
    @Observable
    class ViewModel {
        var favoriteSongs: [Song] = []
        var isLoading: Bool = false
        
        var lastFetched: Date?
        let cacheLifetime: TimeInterval = 300
        
        func fetchSongs(forceRefresh: Bool = false) {
            if !forceRefresh,
                let lastFetched,
                Date().timeIntervalSince(lastFetched) < cacheLifetime,
                !favoriteSongs.isEmpty {
                return
            }
            
            isLoading = true
            let favoritesService = FavoritesService()
            Task { @MainActor in
                self.favoriteSongs = await favoritesService.fetchFavoriteSongs()
                self.lastFetched = Date()
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

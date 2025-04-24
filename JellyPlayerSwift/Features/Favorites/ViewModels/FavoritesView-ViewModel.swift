//
//  FavoritesView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import Foundation

extension FavoritesView {
    @Observable
    class ViewModel {
        var favoriteSongs: [Song] = []
        
        func fetchSongs() {
            let favoritesService = FavoritesService()
            Task { @MainActor in
                self.favoriteSongs = await favoritesService.fetchFavoriteSongs()
            }
        }
    }
}

//
//  FavoritesView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUICore

extension FavoritesView {
    @Observable
    class ViewModel {
        var favoriteSongs: [Song] = []
        var isLoading: Bool = false
        
        func fetchSongs() {
            isLoading = true
            let favoritesService = FavoritesService()
            Task { @MainActor in
                self.favoriteSongs = await favoritesService.fetchFavoriteSongs()
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

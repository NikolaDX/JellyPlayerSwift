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
        let libraryService = LibraryService.shared
        
        var favoriteSongs: [Song] {
            libraryService.fetchFavorites()
        }
        
        var isLoading: Bool {
            libraryService.isLoading && favoriteSongs.isEmpty
        }
    }
}

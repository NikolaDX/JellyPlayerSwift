//
//  GenreDetailsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import Foundation

extension GenreDetailsView {
    @Observable
    class ViewModel {
        let genre: Genre
        var genreAlbums: [Album] = []
        
        init(genre: Genre) {
            self.genre = genre
        }
        
        func fetchGenreAlbums() {
            let genresService = GenresService()
            Task { @MainActor in
                self.genreAlbums = await genresService.fetchGenreAlbums(genreId: genre.Id)
            }
        }
    }
}

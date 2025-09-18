//
//  GenreDetailsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

extension GenreDetailsView {
    @Observable
    class ViewModel {
        let genre: Genre
        var genreAlbums: [Album] = []
        var isLoading: Bool = false
        
        init(genre: Genre) {
            self.genre = genre
        }
        
        func fetchGenreAlbums() {
            if !genreAlbums.isEmpty { return }
            isLoading = true
            let genresService = GenresService()
            Task { @MainActor in
                self.genreAlbums = await genresService.fetchGenreAlbums(genreId: genre.Id)
                withAnimation {
                    isLoading = false
                }
            }
        }
        
        func playGenre() async {
            let albumService = AlbumService()
            var songs: [Song] = []
            
            for album in genreAlbums {
                songs = await songs + albumService.fetchAlbumSongs(albumId: album.Id)
            }
            
            if !songs.isEmpty {
                PlaybackService.shared.playAndBuildQueue(songs[0], songsToPlay: songs)
            }
        }
        
        func shuffleGenre() async {
            let albumService = AlbumService()
            var songs: [Song] = []
            
            for album in genreAlbums {
                songs = await songs + albumService.fetchAlbumSongs(albumId: album.Id)
            }
            
            if !songs.isEmpty {
                songs = songs.shuffled()
                PlaybackService.shared.playAndBuildQueue(songs[0], songsToPlay: songs)
            }
        }
    }
}

//
//  ArtistDetailsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

extension ArtistDetailsView {
    @Observable
    class ViewModel {
        let artist: Artist
        var artistAlbums: [Album] = []
        var isLoading: Bool = false
        
        init(artist: Artist) {
            self.artist = artist
        }
        
        func fetchArtistAlbums() {
            if !artistAlbums.isEmpty { return }
            isLoading = true
            let artistsService = ArtistsService()
            Task { @MainActor in
                self.artistAlbums = await artistsService.fetchArtistAlbums(artistId: artist.Id)
                withAnimation {
                    isLoading = false
                }
            }
        }
        
        func playArtist() async {
            let albumService = AlbumService()
            var songs: [Song] = []
            
            for album in artistAlbums {
                songs = await songs + albumService.fetchAlbumSongs(albumId: album.Id)
            }
            
            if !songs.isEmpty {
                PlaybackService.shared.playAndBuildQueue(songs[0], songsToPlay: songs)
            }
        }
        
        func shuffleArtist() async {
            let albumService = AlbumService()
            var songs: [Song] = []
            
            for album in artistAlbums {
                songs = await songs + albumService.fetchAlbumSongs(albumId: album.Id)
            }
            
            if !songs.isEmpty {
                songs = songs.shuffled()
                PlaybackService.shared.playAndBuildQueue(songs[0], songsToPlay: songs)
            }
        }
    }
}

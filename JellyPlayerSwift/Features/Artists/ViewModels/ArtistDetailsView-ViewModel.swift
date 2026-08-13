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
        var artistAlbums: [Album] {
            LibraryService.shared.fetchArtistAlbums(for: artist.Id)
        }
        
        var isLoading: Bool {
            LibraryService.shared.isLoading && artistAlbums.isEmpty
        }
        
        init(artist: Artist) {
            self.artist = artist
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

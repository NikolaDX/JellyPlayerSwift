//
//  AlbumTracksView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Foundation

extension AlbumTracksView {
    @Observable
    class ViewModel {
        let album: Album
        var songs: [Song] = []
        
        init(album: Album) {
            self.album = album
        }
        
        func fetchSongs() {
            let albumService = AlbumService()
            Task { @MainActor in
                songs = await albumService.fetchAlbumSongs(albumId: album.Id)
            }
        }
        
        func playSong(_ song: Song) {
            PlaybackService.shared.playAndBuildQueue(song, songsToPlay: songs)
        }
        
        func shufflePlay() {
            let shuffledSongs = songs.shuffled()
            PlaybackService.shared.playAndBuildQueue(shuffledSongs[0], songsToPlay: shuffledSongs)
        }
        
        func formatTime(_ time: Double) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

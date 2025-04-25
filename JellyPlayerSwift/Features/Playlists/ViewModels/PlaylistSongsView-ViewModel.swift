//
//  PlaylistSongsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import Foundation

extension PlaylistSongsView {
    @Observable
    class ViewModel {
        var songs: [Song] = []
        
        let playlist: Playlist
        
        init(playlist: Playlist) {
            self.playlist = playlist
        }
        
        func fetchSongs() {
            let playlistsService = PlaylistsService()
            Task { @MainActor in
                songs = await playlistsService.fetchPlaylistSongs(playlistId: playlist.Id)
            }
        }
    }
}

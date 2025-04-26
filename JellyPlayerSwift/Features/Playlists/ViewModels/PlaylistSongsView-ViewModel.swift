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
        
        func removeSongsFromPlaylist(songIds: [String], playlistId: String) {
            let playlistsSerivce = PlaylistsService()
            Task { @MainActor in
                do {
                    try await playlistsSerivce.removeSongsFromPlaylist(songIds: songIds, playlistId: playlistId)
                    fetchSongs()
                } catch {
                    print("Error removing song: \(error.localizedDescription)")
                }
            }
        }
    }
}

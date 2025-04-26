//
//  AddSongToPlaylistView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/26/25.
//

import Foundation

extension AddSongToPlaylistView {
    @Observable
    class ViewModel {
        var playlists: [Playlist] = []
        var showingSuccessMessage: Bool = false
        var errorMessage: String? = nil
        var isLoading: Bool = false
        
        func fetchPlaylists() {
            let playlistsService = PlaylistsService()
            Task { @MainActor in
                self.playlists = await playlistsService.fetchPlaylists()
            }
        }
        
        func addSongToPlaylist(songId: String, playlistId: String) {
            errorMessage = nil
            isLoading = true
            let playlistsSerivce = PlaylistsService()
            Task { @MainActor in
                do {
                    try await playlistsSerivce.addSongsToPlaylist(songIds: [songId], playlistId: playlistId)
                    self.showingSuccessMessage = true
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
            isLoading = false
        }
    }
}

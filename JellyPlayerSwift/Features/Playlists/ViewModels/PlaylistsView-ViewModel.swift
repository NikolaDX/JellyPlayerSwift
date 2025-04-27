//
//  PlaylistsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import Foundation

extension PlaylistsView {
    @Observable
    class ViewModel {
        var playlists: [Playlist] = []
        
        var filterText: String = ""
        
        var filteredPlaylists: [Playlist] {
            filterText.isEmpty ? playlists : playlists.filter {
                $0.Name.localizedCaseInsensitiveContains(filterText)
            }
        }
        
        func fetchPlaylists() {
            let playlistsService = PlaylistsService()
            Task { @MainActor in
                self.playlists = await playlistsService.fetchPlaylists()
            }
        }
        
        func deletePlaylist(playlistId: String) {
            let playlistsService = PlaylistsService()
            Task { @MainActor in
                do {
                    try await playlistsService.deletePlaylist(playlistId: playlistId)
                    fetchPlaylists()
                } catch {
                    print("Error deleting playlist: \(error.localizedDescription)")
                }
            }
        }
    }
}

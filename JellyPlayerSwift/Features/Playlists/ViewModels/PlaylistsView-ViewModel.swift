//
//  PlaylistsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUICore

extension PlaylistsView {
    @Observable
    class ViewModel {
        var playlists: [Playlist] = []
        var isLoading: Bool = false
        
        var selectedSortOption: String = "Name"
        var selectedSortOrder: String = "Ascending"
        var filterText: String = ""
        
        var sortedPlaylists: [Playlist] {
            let sorted: [Playlist]
            
            switch selectedSortOption {
            case "Name":
                sorted = playlists.sorted { $0.Name < $1.Name }
            case "DateCreated":
                sorted = playlists.sorted { $0.DateCreated < $1.DateCreated }
            default:
                sorted = playlists
            }
            
            if selectedSortOrder == "Descending" {
                return sorted.reversed()
            } else {
                return sorted
            }
        }
        
        var filteredPlaylists: [Playlist] {
            filterText.isEmpty ? sortedPlaylists : sortedPlaylists.filter {
                $0.Name.localizedCaseInsensitiveContains(filterText)
            }
        }
        
        func fetchPlaylists() {
            isLoading = true
            let playlistsService = PlaylistsService()
            Task { @MainActor in
                self.playlists = await playlistsService.fetchPlaylists()
                withAnimation {
                    isLoading = false
                }
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
        
        func generateInsantMix(playlistId: String) {
            let playlistsService = PlaylistsService()
            Task {
                let instantMixSongs = await playlistsService.generateInstantMix(playlistId: playlistId)
                if !instantMixSongs.isEmpty {
                    PlaybackService.shared.playAndBuildQueue(instantMixSongs[0], songsToPlay: instantMixSongs)
                }
            }
        }
        
        func downloadPlaylist(playlistId: String) {
            let playlistsService = PlaylistsService()
            Task {
                await playlistsService.downloadPlaylistSongs(playlistId: playlistId)
            }
        }
    }
}

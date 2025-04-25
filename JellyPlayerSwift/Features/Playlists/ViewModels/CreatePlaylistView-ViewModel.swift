//
//  CreatePlaylistView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import Foundation

extension CreatePlaylistView {
    @Observable
    class ViewModel {
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var showingSuccessMessage: Bool = false
        var playlistName: String = ""
        
        func createPlaylist() {
            errorMessage = nil
            self.isLoading = true
            let playlistsSerivce = PlaylistsService()
            Task { @MainActor in
                do {
                    try await playlistsSerivce.createPlaylist(playlistName: playlistName)
                    showingSuccessMessage = true
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
            self.isLoading = false
        }
    }
}

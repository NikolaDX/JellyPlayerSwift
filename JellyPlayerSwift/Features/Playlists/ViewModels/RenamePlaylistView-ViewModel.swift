//
//  RenamePlaylistView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/3/25.
//

import Foundation

extension RenamePlaylistView {
    @Observable
    class ViewModel {
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var showingSuccessMessage: Bool = false
        var newPlaylistName: String = ""
        let playlistId: String
        
        init(playlistId: String) {
            self.playlistId = playlistId
        }
        
        func renamePlaylist() {
            errorMessage = nil
            self.isLoading = true
            let playlistsSerivce = PlaylistsService()
            Task { @MainActor in
                do {
                    try await playlistsSerivce.renamePlaylist(playlistId: playlistId, newName: newPlaylistName)
                    showingSuccessMessage = true
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
            self.isLoading = false
        }
    }
}

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
            isLoading = true

            let playlistsService = PlaylistsService()

            Task { @MainActor in
                defer {
                    isLoading = false
                }

                do {
                    try await playlistsService.renamePlaylist(
                        playlistId: playlistId,
                        newName: newPlaylistName
                    )

                    LibraryService.shared.renamePlaylist(
                        id: playlistId,
                        newName: newPlaylistName
                    )

                    showingSuccessMessage = true
                    
                    print(LibraryService.shared.playlists.map(\.Name))

                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

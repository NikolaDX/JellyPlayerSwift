//
//  AddItems-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/26/25.
//

import Foundation

extension AddItemsView {
    @Observable
    class ViewModel {
        let playlistId: String
        let refreshAction: () -> Void
        var songs: [Song] = []
        
        init(playlistId: String, refreshAction: @escaping () -> Void) {
            self.playlistId = playlistId
            self.refreshAction = refreshAction
        }
        
        func fetchAllSongs() {
            let songsService = SongsService()
            Task { @MainActor in
                self.songs = await songsService.fetchAllSongs()
            }
        }
        
        func addSongsToPlaylist(songIds: [String]) {
            let playlistsSerivce = PlaylistsService()
            Task { @MainActor in
                do {
                    try await playlistsSerivce.addSongsToPlaylist(songIds: songIds, playlistId: playlistId)
                    self.refreshAction()
                } catch {
                    print("Error removing song: \(error.localizedDescription)")
                }
            }
        }
    }
}

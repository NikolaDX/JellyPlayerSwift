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
        let existingSongIds: Set<String>
        private var allSongs: [Song] = []
        let onSongsAdded: ([Song]) -> Void
        
        var songs: [Song] {
            allSongs.filter { !existingSongIds.contains($0.Id) }
        }
        
        init(playlistId: String, existingSongIds: Set<String>, onSongsAdded: @escaping ([Song]) -> Void) {
            self.playlistId = playlistId
            self.existingSongIds = existingSongIds
            self.onSongsAdded = onSongsAdded
        }
        
        func fetchAllSongs() {
            let songsService = SongsService()
            Task { @MainActor in
                self.allSongs = await songsService.fetchAllSongs()
            }
        }
        
        func addSongsToPlaylist(songIds: [String]) {
            let playlistsSerivce = PlaylistsService()
            let addedSongs = allSongs.filter { songIds.contains($0.Id) }
            Task { @MainActor in
                do {
                    try await playlistsSerivce.addSongsToPlaylist(songIds: songIds, playlistId: playlistId)
                    onSongsAdded(addedSongs)
                } catch {
                    print("Error removing song: \(error.localizedDescription)")
                }
            }
        }
    }
}

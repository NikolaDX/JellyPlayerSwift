//
//  SongsLibraryView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import Foundation

extension SongsLibraryView {
    @Observable
    class ViewModel {
        var songs: [Song] = []
        
        func fetchSongs() {
            let songsService = SongsService()
            Task { @MainActor in
                self.songs = await songsService.fetchAllSongs()
            }
        }
    }
}

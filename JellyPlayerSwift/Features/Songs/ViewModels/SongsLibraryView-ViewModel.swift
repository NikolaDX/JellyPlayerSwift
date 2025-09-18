//
//  SongsLibraryView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

extension SongsLibraryView {
    @Observable
    class ViewModel {
        var songs: [Song] = []
        var isLoading: Bool = false
        
        func fetchSongs() {
            if !songs.isEmpty { return }
            isLoading = true
            let songsService = SongsService()
            Task { @MainActor in
                self.songs = await songsService.fetchAllSongs()
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

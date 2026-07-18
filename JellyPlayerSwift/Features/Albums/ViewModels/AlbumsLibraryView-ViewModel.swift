//
//  AlbumsLibraryView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

extension AlbumsLibraryView {
    @Observable
    class ViewModel {
        var albums: [Album] = []
        var isLoading: Bool = false
        
        var lastFetched: Date?
        let cacheLifetime: TimeInterval = 300
        
        func fetchAlbums(forceRefresh: Bool = false) {
            if !albums.isEmpty { return }
            
            if !forceRefresh,
                let lastFetched,
                Date().timeIntervalSince(lastFetched) < cacheLifetime,
                !albums.isEmpty {
                return
            }
            
            isLoading = true
            let albumsService = AlbumService()
            Task { @MainActor in
                self.albums = await albumsService.fetchAlbums()
                self.fetchAlbums(forceRefresh: true)
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

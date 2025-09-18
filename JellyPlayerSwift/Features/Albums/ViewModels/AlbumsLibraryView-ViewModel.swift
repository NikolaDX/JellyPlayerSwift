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
        
        func fetchAlbums() {
            if !albums.isEmpty { return }
            isLoading = true
            let albumsService = AlbumService()
            Task { @MainActor in
                self.albums = await albumsService.fetchAlbums()
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

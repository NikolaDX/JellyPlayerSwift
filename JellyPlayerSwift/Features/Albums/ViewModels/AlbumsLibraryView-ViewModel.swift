//
//  AlbumsLibraryView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import Foundation

extension AlbumsLibraryView {
    @Observable
    class ViewModel {
        var albums: [Album] = []
        
        func fetchAlbums() {
            let albumsService = AlbumService()
            Task { @MainActor in
                self.albums = await albumsService.fetchAlbums()
            }
        }
    }
}

//
//  AlbumsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Foundation

extension AlbumsView {
    @Observable
    class ViewModel {
        var albums: [Album] = []
        
        func fetchAlbums() {
            let albumService = AlbumService()
            Task { @MainActor in
                self.albums = await albumService.fetchAlbums()
            }
        }
    }
}

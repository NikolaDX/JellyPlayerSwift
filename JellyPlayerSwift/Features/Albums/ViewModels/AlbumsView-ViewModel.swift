//
//  AlbumsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Foundation

extension AlbumsStackView {
    @Observable
    class ViewModel {
        var albums: [Album] = []
        
        func fetchAlbums() {
            let albumService = AlbumService()
            Task { @MainActor in
                self.albums = await albumService.fetchAlbums()
            }
        }
        
        func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
            min(max(value, lower), upper)
        }
    }
}

//
//  AlbumsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUICore

extension AlbumsStackView {
    @Observable
    class ViewModel {
        var albums: [Album] = []
        var isLoading: Bool = false
        
        func fetchAlbums() {
            if !albums.isEmpty { return }
            isLoading = true
            let albumService = AlbumService()
            Task { @MainActor in
                self.albums = await albumService.fetchAlbums()
                withAnimation {
                    isLoading = false
                }
            }
        }
        
        func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
            min(max(value, lower), upper)
        }
    }
}

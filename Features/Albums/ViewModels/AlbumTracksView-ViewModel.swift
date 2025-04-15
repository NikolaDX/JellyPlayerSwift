//
//  AlbumTracksView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Foundation

extension AlbumTracksView {
    @Observable
    class ViewModel {
        let album: Album
        var songs: [Song] = []
        
        init(album: Album) {
            self.album = album
        }
        
        func fetchSongs() {
            let albumService = AlbumService()
            Task { @MainActor in
                songs = await albumService.fetchAlbumSongs(albumId: album.Id)
            }
        }
    }
}

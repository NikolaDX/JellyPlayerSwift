//
//  ArtistDetailsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import Foundation

extension ArtistDetailsView {
    @Observable
    class ViewModel {
        let artist: Artist
        var artistAlbums: [Album] = []
        
        init(artist: Artist) {
            self.artist = artist
        }
        
        func fetchArtistAlbums() {
            let artistsService = ArtistsService()
            Task { @MainActor in
                self.artistAlbums = await artistsService.fetchArtistAlbums(artistId: artist.Id)
            }
        }
    }
}

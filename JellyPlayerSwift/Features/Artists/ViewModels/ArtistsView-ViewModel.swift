//
//  ArtistsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import Foundation

extension ArtistsView {
    @Observable
    class ViewModel {
        var artists: [Artist] = []
        
        var filterText: String = ""
        
        var filteredArtists: [Artist] {
            filterText.isEmpty ? artists : artists.filter {
                $0.Name.localizedStandardContains(filterText)
            }
        }
        
        var artistsByLetter: [String: [Artist]] {
            Dictionary(grouping: filteredArtists) { artist in
                String(artist.Name.prefix(1).uppercased())
            }
        }
        
        var sortedLetters: [String] {
            artistsByLetter.keys.sorted()
        }
        
        func fetchArtists() {
            let artistsService = ArtistsService()
            Task { @MainActor in
                self.artists = await artistsService.fetchArtists()
            }
        }
    }
}

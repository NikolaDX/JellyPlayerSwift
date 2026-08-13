//
//  ArtistsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

extension ArtistsView {
    @Observable
    class ViewModel {
        var artists: [Artist] {
            LibraryService.shared.artists
        }
        
        var isLoading: Bool {
            LibraryService.shared.isLoading && artists.isEmpty
        }
        
        var filterText: String = ""
        
        var lastFetched: Date?
        let cacheLifetime: TimeInterval = 300
        
        var filteredArtists: [Artist] {
            filterText.isEmpty ? artists : artists.filter {
                $0.Name.localizedStandardContains(filterText)
            }
        }
        
        func generateInsantMix(artistId: String) {
            let artistsService = ArtistsService()
            Task {
                let instantMixSongs = await artistsService.generateInstantMix(artistId: artistId)
                if !instantMixSongs.isEmpty {
                    PlaybackService.shared.playAndBuildQueue(instantMixSongs[0], songsToPlay: instantMixSongs)
                }
            }
        }
    }
}

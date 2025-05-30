//
//  ArtistsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUICore

extension ArtistsView {
    @Observable
    class ViewModel {
        var artists: [Artist] = []
        var isLoading: Bool = false
        
        var filterText: String = ""
        
        var filteredArtists: [Artist] {
            filterText.isEmpty ? artists : artists.filter {
                $0.Name.localizedStandardContains(filterText)
            }
        }
        
        func fetchArtists() {
            isLoading = true
            let artistsService = ArtistsService()
            Task { @MainActor in
                self.artists = await artistsService.fetchArtists()
                withAnimation {
                    isLoading = false
                }
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

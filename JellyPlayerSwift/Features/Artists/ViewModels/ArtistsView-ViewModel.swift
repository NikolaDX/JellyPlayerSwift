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
        var artists: [Artist] = []
        var isLoading: Bool = false
        
        var filterText: String = ""
        
        var lastFetched: Date?
        let cacheLifetime: TimeInterval = 300
        
        var filteredArtists: [Artist] {
            filterText.isEmpty ? artists : artists.filter {
                $0.Name.localizedStandardContains(filterText)
            }
        }
        
        func fetchArtists(forceRefresh: Bool = false) {
            if !forceRefresh,
                let lastFetched,
                Date().timeIntervalSince(lastFetched) < cacheLifetime,
                !artists.isEmpty {
                return
            }
            
            isLoading = true
            let artistsService = ArtistsService()
            Task { @MainActor in
                self.artists = await artistsService.fetchArtists()
                self.lastFetched = Date()
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

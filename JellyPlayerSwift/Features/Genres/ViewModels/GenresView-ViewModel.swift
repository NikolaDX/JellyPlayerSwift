//
//  GenresView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

extension GenresView {
    @Observable
    class ViewModel {
        var genres: [Genre] = []
        var isLoading: Bool = false
        
        var filterText: String = ""
        
        var lastFetched: Date?
        let cacheLifetime: TimeInterval = 300
        
        var filteredGenres: [Genre] {
            filterText.isEmpty ? genres : genres.filter {
                $0.Name.localizedCaseInsensitiveContains(filterText)
            }
        }
        
        func fetchGenres(forceRefresh: Bool = false) {
            if !forceRefresh,
                let lastFetched,
                Date().timeIntervalSince(lastFetched) < cacheLifetime,
                !genres.isEmpty {
                return
            }
            
            isLoading = true
            let genresService = GenresService()
            Task { @MainActor in
                self.genres = await genresService.fetchGenres()
                self.lastFetched = Date()
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

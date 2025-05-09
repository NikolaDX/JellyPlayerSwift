//
//  GenresView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUICore

extension GenresView {
    @Observable
    class ViewModel {
        var genres: [Genre] = []
        var isLoading: Bool = false
        
        var filterText: String = ""
        
        var filteredGenres: [Genre] {
            filterText.isEmpty ? genres : genres.filter {
                $0.Name.localizedCaseInsensitiveContains(filterText)
            }
        }
        
        func fetchGenres() {
            isLoading = true
            let genresService = GenresService()
            Task { @MainActor in
                self.genres = await genresService.fetchGenres()
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

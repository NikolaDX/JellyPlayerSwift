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
        var genres: [Genre] {
            LibraryService.shared.genres
        }
        
        var isLoading: Bool {
            LibraryService.shared.isLoading && genres.isEmpty
        }
        
        var filterText: String = ""
        
        var filteredGenres: [Genre] {
            filterText.isEmpty ? genres : genres.filter {
                $0.Name.localizedCaseInsensitiveContains(filterText)
            }
        }
    }
}

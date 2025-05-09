//
//  GenresView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

struct GenresView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        AsyncView(isLoading: $viewModel.isLoading) {
            List(viewModel.filteredGenres, id: \.Id) { genre in
                NavigationLink(destination: GenreDetailsView(genre: genre)) {
                    Headline(genre.Name)
                }
                .foregroundStyle(.primary)
                .accessibilityLabel("Genre: \(genre.Name)")
            }
            .navigationTitle("Genres")
            .searchable(text: $viewModel.filterText, prompt: "Search for a genre...")
        }
        .task {
            viewModel.fetchGenres()
        }
    }
}

#Preview {
    GenresView()
}

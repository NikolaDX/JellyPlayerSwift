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
        List(viewModel.filteredGenrers, id: \.Id) { genre in
            NavigationLink(destination: GenreDetailsView(genre: genre)) {
                Headline(genre.Name)
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle("Genres")
        .searchable(text: $viewModel.filterText, prompt: "Search for a genre...")
        .task {
            viewModel.fetchGenres()
        }
    }
}

#Preview {
    GenresView()
}

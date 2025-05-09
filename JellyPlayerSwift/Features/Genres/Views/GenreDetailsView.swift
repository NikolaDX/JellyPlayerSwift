//
//  GenreDetailsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

struct GenreDetailsView: View {
    @State private var viewModel: ViewModel
    
    init(genre: Genre) {
        viewModel = ViewModel(genre: genre)
    }
    
    var body: some View {
        AsyncView(isLoading: $viewModel.isLoading) {
            AlbumsGridView(albums: viewModel.genreAlbums)
                .navigationTitle(viewModel.genre.Name)
                .toolbar {
                    IconButton(icon: Image(systemName: "play.fill")) {
                        Task {
                            await viewModel.playGenre()
                        }
                    }
                    .accessibilityHint("Play all songs of this genre")
                    
                    IconButton(icon: Image(systemName: "shuffle")) {
                        Task {
                            await viewModel.shuffleGenre()
                        }
                    }
                    .accessibilityLabel("Shuffle")
                    .accessibilityHint("Shuffle songs of this genre")
                }
        }
        .task {
            viewModel.fetchGenreAlbums()
        }
    }
}

#Preview {
    GenreDetailsView(genre: Genre(Id: "Id", Name: "Name"))
}

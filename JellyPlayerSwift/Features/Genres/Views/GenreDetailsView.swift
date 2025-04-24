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
        AlbumsGridView(albums: viewModel.genreAlbums)
            .navigationTitle(viewModel.genre.Name)
            .task {
                viewModel.fetchGenreAlbums()
            }
    }
}

#Preview {
    GenreDetailsView(genre: Genre(Id: "Id", Name: "Name"))
}

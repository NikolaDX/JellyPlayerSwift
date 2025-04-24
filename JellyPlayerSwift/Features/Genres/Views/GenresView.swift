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
        List(viewModel.genres, id: \.Id) { genre in
            NavigationLink(destination: GenreDetailsView(genre: genre)) {
                Headline(genre.Name)
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle("Genres")
        .task {
            viewModel.fetchGenres()
        }
    }
}

#Preview {
    GenresView()
}

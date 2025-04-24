//
//  FavoritesView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

struct FavoritesView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        SongsView(songs: viewModel.favoriteSongs)
            .navigationTitle("Favorites")
            .task {
                viewModel.fetchSongs()
            }
    }
}

#Preview {
    FavoritesView()
}

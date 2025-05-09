//
//  AlbumsLibraryView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

struct AlbumsLibraryView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        AsyncView(isLoading: $viewModel.isLoading) {
            AlbumsGridView(albums: viewModel.albums)
        }
        .navigationTitle("Albums")
        .task {
            viewModel.fetchAlbums()
        }
    }
}

#Preview {
    AlbumsLibraryView()
}

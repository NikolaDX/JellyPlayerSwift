//
//  PlaylistsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUI

struct PlaylistsView: View {
    @State private var viewModel = ViewModel()
    @State private var showingPlaylistCreation: Bool = false
    
    var body: some View {
        List(viewModel.playlists, id: \.Id) { playlist in
            NavigationLink {
                PlaylistSongsView(playlist: playlist)
            } label: {
                PlaylistRow(playlist)
            }
        }
        .navigationTitle("Playlists")
        .toolbar {
            IconButton(icon: Image(systemName: "plus.circle.fill")) {
                showingPlaylistCreation = true
            }
        }
        .onChange(of: showingPlaylistCreation) { _, newValue in
            if !newValue {
                viewModel.fetchPlaylists()
            }
        }
        .sheet(isPresented: $showingPlaylistCreation) {
            CreatePlaylistView()
        }
        .task {
            viewModel.fetchPlaylists()
        }
    }
}

#Preview {
    PlaylistsView()
}

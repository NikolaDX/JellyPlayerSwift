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
    @State private var playlistToRemove: Playlist? = nil
    @State private var showingRemovePlaylist: Bool = false
    
    var body: some View {
        List {
            ForEach(viewModel.filteredPlaylists, id: \.Id) { playlist in
                NavigationLink {
                    PlaylistSongsView(playlist: playlist)
                } label: {
                    PlaylistRow(playlist)
                }
                .contextMenu {
                    ContextButton(isDestructive: true, text: "Delete playlist", systemImage: "trash") {
                        playlistToRemove = playlist
                        showingRemovePlaylist = true
                    }
                    
                    ContextButton(isDestructive: false, text: "Instant mix", systemImage: "safari") {
                        viewModel.generateInsantMix(playlistId: playlist.Id)
                    }
                    
                    ContextButton(isDestructive: false, text: "Download playlist", systemImage: "arrow.down.circle") {
                        viewModel.downloadPlaylist(playlistId: playlist.Id)
                    }
                }
            }
            .onDelete(perform: deleteRows)
        }
        .navigationTitle("Playlists")
        .searchable(text: $viewModel.filterText, prompt: "Search for a playlist...")
        .toolbar {
            IconButton(icon: Image(systemName: "plus.circle.fill")) {
                showingPlaylistCreation = true
            }
            
            EditButton()
        }
        .onChange(of: showingPlaylistCreation) { _, newValue in
            if !newValue {
                viewModel.fetchPlaylists()
            }
        }
        .sheet(isPresented: $showingPlaylistCreation) {
            CreatePlaylistView()
        }
        .alert("Remove playlist", isPresented: $showingRemovePlaylist, presenting: playlistToRemove) { playlist in
            Button("Remove", role: .destructive) {
                viewModel.deletePlaylist(playlistId: playlist.Id)
            }
            Button("Cancel", role: .cancel) { }
        } message: { playlist in
            Text("Are you sure you want to remove \"\(playlist.Name)\"?")
        }
        .task {
            viewModel.fetchPlaylists()
        }
    }
    
    func deleteRows(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deletePlaylist(playlistId: viewModel.playlists[index].Id)
        }
    }
}

#Preview {
    PlaylistsView()
}

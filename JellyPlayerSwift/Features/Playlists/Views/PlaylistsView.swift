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
    @State private var playlistToRename: Playlist? = nil
    @State private var showingRenamePlaylist: Bool = false
    
    var body: some View {
        AsyncView(isLoading: $viewModel.isLoading) {
            List {
                ForEach(viewModel.filteredPlaylists, id: \.Id) { playlist in
                    NavigationLink {
                        PlaylistSongsView(playlist: playlist)
                    } label: {
                        PlaylistRow(playlist)
                    }
                    .accessibilityLabel("Playlist: \(playlist.Name), contains \(playlist.NumberOfSongs ?? 0) songs.")
                    .contextMenu {
                        ContextButton(isDestructive: true, text: "Delete playlist", systemImage: "trash") {
                            playlistToRemove = playlist
                            showingRemovePlaylist = true
                        }
                        .accessibilityHint("Deletes playlist permanently")
                        
                        ContextButton(isDestructive: false, text: "Instant mix", systemImage: "safari") {
                            viewModel.generateInsantMix(playlistId: playlist.Id)
                        }
                        .accessibilityHint("Creates mix based on songs from this playlist")
                        
                        ContextButton(isDestructive: false, text: "Download playlist", systemImage: "arrow.down.circle") {
                            viewModel.downloadPlaylist(playlistId: playlist.Id)
                        }
                        .accessibilityHint("Downloads playlist songs for offline listening")
                        
                        ContextButton(isDestructive: false, text: "Rename playlist", systemImage: "pencil") {
                            playlistToRename = nil
                            DispatchQueue.main.async {
                                playlistToRename = playlist
                            }
                        }
                        .accessibilityHint("Change the name of the playlist")
                    }
                }
                .onDelete(perform: deleteRows)
            }
            .searchable(text: $viewModel.filterText, prompt: "Search for a playlist...")
            .toolbar {
                IconButton(icon: Image(systemName: "plus.circle.fill")) {
                    showingPlaylistCreation = true
                }
                .accessibilityHint("Create a new playlist")
                
                Menu("Sort by", systemImage: "arrow.up.arrow.down") {
                    Menu("Sort order") {
                        Picker("Sort order", selection: $viewModel.selectedSortOrder) {
                            Text("Ascending").tag("Ascending")
                            Text("Descending").tag("Descending")
                        }
                        .accessibilityHint("Select sort order")
                    }
                    
                    Menu("Sort by") {
                        Picker("Sort by", selection: $viewModel.selectedSortOption) {
                            Text("Name").tag("Name")
                            Text("Date created").tag("DateCreated")
                        }
                        .accessibilityHint("Select sort option")
                    }
                }
                .accessibilityHint("Sort songs in this playlist")
                
                EditButton()
                    .accessibilityLabel("Edit playlists")
            }
            .onChange(of: showingPlaylistCreation) { _, newValue in
                if !newValue {
                    viewModel.fetchPlaylists()
                }
            }
            .onChange(of: playlistToRename) {
                if let _ = playlistToRename {
                    showingRenamePlaylist = true
                }
            }
            .onChange(of: showingRenamePlaylist) { _, newValue in
                if !newValue {
                    DispatchQueue.main.async {
                        viewModel.fetchPlaylists()
                    }
                }
            }
            .sheet(isPresented: $showingPlaylistCreation) {
                CreatePlaylistView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingRenamePlaylist) {
                RenamePlaylistView(playlistId: playlistToRename!.Id)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .alert("Remove playlist", isPresented: $showingRemovePlaylist, presenting: playlistToRemove) { playlist in
                Button("Remove", role: .destructive) {
                    viewModel.deletePlaylist(playlistId: playlist.Id)
                }
                Button("Cancel", role: .cancel) { }
            } message: { playlist in
                Text("Are you sure you want to remove \"\(playlist.Name)\"?")
            }
            .navigationTitle("Playlists")
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

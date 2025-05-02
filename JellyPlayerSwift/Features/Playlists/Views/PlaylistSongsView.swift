//
//  PlaylistSongsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUI

struct PlaylistSongsView: View {
    @State private var viewModel: ViewModel
    @State private var showingAddToPlaylist: Bool = false
    @State private var showingAddSong: Bool = false
    @State private var songToAdd: Song? = nil
    @State private var songToRemove: Song? = nil
    @State private var showingRemoveDownloadAlert: Bool = false
    @State private var songToRemoveFromPlaylist: Song? = nil
    @State private var showingRemoveFromPlaylist: Bool = false
    
    init(playlist: Playlist) {
        viewModel = ViewModel(playlist: playlist)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.filteredSongs, id: \.Id) { song in
                Button {
                    viewModel.playFrom(song: song)
                } label: {
                    SongRow(song)
                        .contextMenu {
                            ContextButton(isDestructive: true, text: "Remove from playlist", systemImage: "trash") {
                                songToRemoveFromPlaylist = song
                                showingRemoveFromPlaylist = true
                            }
                            
                            if song.UserData.IsFavorite {
                                ContextButton(isDestructive: true, text: "Remove from favorites", systemImage: "star.slash") {
                                    viewModel.removeFromFavorites(song: song)
                                }
                            } else {
                                ContextButton(isDestructive: false, text: "Add to favorites", systemImage: "star") {
                                    viewModel.addToFavorites(song: song)
                                }
                            }
                            
                            if song.localFilePath != nil {
                                ContextButton(isDestructive: true, text: "Remove download", systemImage: "trash") {
                                    songToRemove = song
                                    showingRemoveDownloadAlert = true
                                }
                            } else {
                                ContextButton(isDestructive: false, text: "Download", systemImage: "arrow.down.circle") {
                                    viewModel.downloadSong(song: song)
                                }
                            }
                            
                            ContextButton(isDestructive: false, text: "Add to playlist", systemImage: "plus.circle") {
                                songToAdd = nil
                                DispatchQueue.main.async {
                                    songToAdd = song
                                }
                            }
                            
                            ContextButton(isDestructive: false, text: "Instant mix", systemImage: "safari") {
                                viewModel.generateInstantMix(songId: song.Id)
                            }
                            
                        }
                }
                .foregroundStyle(.primary)
            }
            .onDelete(perform: deleteRows)
        }
        .onChange(of: songToAdd) {
            if let _ = songToAdd {
                showingAddSong = true
            }
        }
        .navigationTitle(viewModel.playlist.Name)
        .searchable(text: $viewModel.filterText, prompt: "Search for a song...")
        .toolbar {
            IconButton(icon: Image(systemName: "plus.circle.fill")) {
                showingAddToPlaylist = true
            }
            
            Menu("Sort by", systemImage: "arrow.up.arrow.down") {
                Menu("Sort order") {
                    Picker("Sort order", selection: $viewModel.selectedSortOrder) {
                        Text("Ascending").tag("Ascending")
                        Text("Descending").tag("Descending")
                    }
                }
                
                Menu("Sort by") {
                    Picker("Sort by", selection: $viewModel.selectedSortOption) {
                        Text("Playlist order").tag("PlaylistOrder")
                        Text("Name").tag("Name")
                        Text("Album").tag("Album")
                        Text("Artist").tag("Artist")
                        Text("Date added").tag("DateAdded")
                        Text("Play count").tag("PlayCount")
                    }
                }
            }
            
            IconButton(icon: Image(systemName: "play.fill")) {
                viewModel.playAll()
            }
            
            IconButton(icon: Image(systemName: "shuffle")) {
                viewModel.shufflePlay()
            }
            
            EditButton()
        }
        .sheet(isPresented: $showingAddToPlaylist) {
            AddItemsView(playlistId: viewModel.playlist.Id, refreshAction: viewModel.fetchSongs)
        }
        .sheet(isPresented: $showingAddSong) {
            AddSongToPlaylistView(songToAdd!)
        }
        .alert("Remove download", isPresented: $showingRemoveDownloadAlert, presenting: songToRemove) { song in
            Button("Remove", role: .destructive) {
                viewModel.removeDownload(song: song)
            }
            Button("Cancel", role: .cancel) { }
        } message: { song in
            Text("Are you sure you want to remove the download for \"\(song.Name)\"?")
        }
        .alert("Remove from playlist", isPresented: $showingRemoveFromPlaylist, presenting: songToRemoveFromPlaylist) { song in
            Button("Remove", role: .destructive) {
                viewModel.removeSongsFromPlaylist(songIds: [song.Id], playlistId: viewModel.playlist.Id)
            }
            Button("Cancel", role: .cancel) { }
        } message: { song in
            Text("Are you sure you want to remove \"\(song.Name)\" from playlist?")
        }
        .task {
            viewModel.fetchSongs()
        }
    }
    
    func deleteRows(at offsets: IndexSet) {
        for index in offsets {
            viewModel.removeSongsFromPlaylist(songIds: [viewModel.songs[index].Id], playlistId: viewModel.playlist.Id)
        }
    }
}

#Preview {
    PlaylistSongsView(playlist: Playlist(Id: "Id", Name: "Name"))
}

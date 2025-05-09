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
    @StateObject private var favoritesService: FavoritesService
    @StateObject private var downloadService: DownloadService
    
    init(playlist: Playlist) {
        let favorites = FavoritesService()
        let downloads = DownloadService.shared
        
        _favoritesService = StateObject(wrappedValue: favorites)
        _downloadService = StateObject(wrappedValue: downloads)
        viewModel = ViewModel(playlist: playlist, favoritesService: favorites, downloadService: downloads)
    }
    
    var body: some View {
        AsyncView(isLoading: $viewModel.isLoading) {
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
                                .accessibilityHint("Remove song from this playlist")
                                
                                if song.UserData.IsFavorite {
                                    ContextButton(isDestructive: true, text: "Remove from favorites", systemImage: "star.slash") {
                                        viewModel.removeFromFavorites(song: song)
                                    }
                                    .accessibilityHint("Remove this song from favorites")
                                } else {
                                    ContextButton(isDestructive: false, text: "Add to favorites", systemImage: "star") {
                                        viewModel.addToFavorites(song: song)
                                    }
                                    .accessibilityHint("Add this song to favorites")
                                }
                                
                                if song.localFilePath != nil {
                                    ContextButton(isDestructive: true, text: "Remove download", systemImage: "trash") {
                                        songToRemove = song
                                        showingRemoveDownloadAlert = true
                                    }
                                    .accessibilityHint("Remove this song from downloads")
                                } else {
                                    ContextButton(isDestructive: false, text: "Download", systemImage: "arrow.down.circle") {
                                        viewModel.downloadSong(song: song)
                                    }
                                    .accessibilityHint("Download this song for offline listening")
                                }
                                
                                ContextButton(isDestructive: false, text: "Add to playlist", systemImage: "plus.circle") {
                                    songToAdd = nil
                                    DispatchQueue.main.async {
                                        songToAdd = song
                                    }
                                }
                                .accessibilityHint("Add this song to another playlist")
                                
                                ContextButton(isDestructive: false, text: "Instant mix", systemImage: "safari") {
                                    viewModel.generateInstantMix(songId: song.Id)
                                }
                                .accessibilityHint("Create mix based on this song")
                            }
                    }
                    .accessibilityLabel("Song: \(song.Name) by \(song.Artists.joined(separator: ", "))")
                    .accessibilityHint("Double-tap to play")
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
                .accessibilityHint("Add songs to this playlist")
                
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
                            Text("Playlist order").tag("PlaylistOrder")
                            Text("Name").tag("Name")
                            Text("Album").tag("Album")
                            Text("Artist").tag("Artist")
                            Text("Date added").tag("DateAdded")
                            Text("Play count").tag("PlayCount")
                        }
                        .accessibilityHint("Select sort option")
                    }
                }
                
                IconButton(icon: Image(systemName: "play.fill")) {
                    viewModel.playAll()
                }
                .accessibilityHint("Play all songs from this playlist")
                
                IconButton(icon: Image(systemName: "shuffle")) {
                    viewModel.shufflePlay()
                }
                .accessibilityLabel("Shuffle")
                .accessibilityHint("Shuffle all songs from this playlist")
                
                EditButton()
                    .accessibilityHint("Remove songs from playlist")
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
                Text("Are you sure you want to remove \"\(song.Name)\" from this playlist?")
            }
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
    PlaylistSongsView(playlist: Playlist(Id: "Id", Name: "Name", DateCreated: ""))
}

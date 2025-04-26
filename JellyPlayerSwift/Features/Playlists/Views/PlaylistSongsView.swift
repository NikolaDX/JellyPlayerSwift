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
    
    init(playlist: Playlist) {
        viewModel = ViewModel(playlist: playlist)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.songs, id: \.Id) { song in
                Button {
                    PlaybackService.shared.playAndBuildQueue(song, songsToPlay: viewModel.songs)
                } label: {
                    SongRow(song)
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.removeSongsFromPlaylist(songIds: [song.Id], playlistId: viewModel.playlist.Id)
                            } label: {
                                Label("Remove from playlist", systemImage: "trash")
                            }
                        }
                }
                .foregroundStyle(.primary)
            }
            .onDelete(perform: deleteRows)
        }
        .navigationTitle(viewModel.playlist.Name)
        .toolbar {
            IconButton(icon: Image(systemName: "plus.circle.fill")) {
                showingAddToPlaylist = true
            }
            
            EditButton()
        }
        .sheet(isPresented: $showingAddToPlaylist) {
            AddItemsView(playlistId: viewModel.playlist.Id, refreshAction: viewModel.fetchSongs)
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

//
//  AddSongToPlaylistView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/26/25.
//

import SwiftUI

struct AddSongToPlaylistView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = ViewModel()
    
    private let song: Song
    
    init(_ song: Song) {
        self.song = song
    }
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    ProgressView()
                        .accessibilityLabel("Adding song to the playlist. Please wait...")
                }
                
                if let error = viewModel.errorMessage {
                    ErrorText(error)
                        .accessibilityLabel("Error: \(error)")
                }
            
                ForEach(viewModel.playlists, id: \.Id) { playlist in
                    PlaylistRow(playlist)
                        .onTapGesture {
                            viewModel.addSongToPlaylist(songId: song.Id, playlistId: playlist.Id)
                        }
                        .accessibilityLabel("Playlist: \(playlist.Name)")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint("Add song to this playlist")
                }
            }
            .task {
                viewModel.fetchPlaylists()
            }
            .navigationTitle("Add song to a playlist")
            .alert("Adding successful!", isPresented: $viewModel.showingSuccessMessage) {
                Button("Great!", role: .cancel) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AddSongToPlaylistView(Song(Id: "Id", Name: "Name", IndexNumber: 1, Album: "Album", AlbumId: "AlbumId", RunTimeTicks: 120000, Artists: ["Artist"], UserData: UserData(IsFavorite: false, PlayCount: 1), DateCreated: ""))
}

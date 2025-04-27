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
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Heading("Add song to a playlist")
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                if let error = viewModel.errorMessage {
                    ErrorText(error)
                }
                
                ForEach(viewModel.playlists, id: \.Id) { playlist in
                    PlaylistRow(playlist)
                        .onTapGesture {
                            viewModel.addSongToPlaylist(songId: song.Id, playlistId: playlist.Id)
                        }
                    Divider()
                }
            }
            .padding(20)
        }
        .task {
            viewModel.fetchPlaylists()
        }
        .alert("Adding successful!", isPresented: $viewModel.showingSuccessMessage) {
            Button("Great!", role: .cancel) {
                dismiss()
            }
        }
    }
}

#Preview {
    AddSongToPlaylistView(Song(Id: "Id", Name: "Name", IndexNumber: 1, Album: "Album", AlbumId: "AlbumId", RunTimeTicks: 120000, Artists: ["Artist"], UserData: UserData(IsFavorite: false, PlayCount: 1), DateCreated: ""))
}

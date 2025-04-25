//
//  PlaylistSongsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUI

struct PlaylistSongsView: View {
    @State private var viewModel: ViewModel
    
    init(playlist: Playlist) {
        viewModel = ViewModel(playlist: playlist)
    }
    
    var body: some View {
        List(viewModel.songs, id: \.Id) { song in
            Button {
                PlaybackService.shared.playAndBuildQueue(song, songsToPlay: viewModel.songs)
            } label: {
                SongRow(song)
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle(viewModel.playlist.Name)
        .task {
            viewModel.fetchSongs()
        }
    }
}

#Preview {
    PlaylistSongsView(playlist: Playlist(Id: "Id", Name: "Name"))
}

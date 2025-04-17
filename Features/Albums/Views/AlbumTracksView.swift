//
//  AlbumTracksView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct AlbumTracksView: View {
    @State private var viewModel: ViewModel
    let spaceBetween: Double = 20
    
    init(album: Album) {
        viewModel = ViewModel(album: album)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                AlbumCover(album: viewModel.album)
                    .padding(.bottom, spaceBetween)
                
                Text(viewModel.album.Name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(viewModel.album.AlbumArtist)
                    .foregroundStyle(.secondary)
                    .font(.headline)
                    .padding(.bottom, spaceBetween)
                
                HStack {
                    NiceIconButton("Play", buttonImage: "play.fill") {
                        viewModel.playSong(viewModel.songs.first!)
                    }
                    
                    NiceIconButton("Shuffle", buttonImage: "shuffle") {
                        
                    }
                }
                .padding(.bottom, spaceBetween)
                
                ForEach(viewModel.songs, id: \.Id) { song in
                    AlbumTrackRow(song)
                        .onTapGesture {
                            viewModel.playSong(song)
                        }
                }
            }
            .padding(spaceBetween)
        }
        .onAppear {
            viewModel.fetchSongs()
        }
    }
}

#Preview {
    @Previewable @Namespace var albumViewAnimation
    AlbumTracksView(album: Album(Id: "id", Name: "Name", AlbumArtist: "Artist"))
}

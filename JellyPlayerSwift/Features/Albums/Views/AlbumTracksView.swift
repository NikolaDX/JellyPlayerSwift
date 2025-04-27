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
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    AlbumCover(album: viewModel.album)
                        .frame(maxHeight: proxy.size.height / 2)
                        .padding(.bottom, spaceBetween)
                    
                    Text(viewModel.album.Name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    NavigationLink(destination: ArtistDetailsView(artist: viewModel.album.AlbumArtists[0])) {
                        Text(viewModel.album.AlbumArtist)
                            .foregroundStyle(.secondary)
                            .font(.headline)
                            .padding(.bottom, spaceBetween)
                    }
                    
                    HStack(spacing: 20) {
                        NiceIconButton("Play", buttonImage: "play.fill") {
                            if (!viewModel.songs.isEmpty) {
                                viewModel.playSong(viewModel.songs[0])
                            }
                        }
                        
                        NiceIconButton("Shuffle", buttonImage: "shuffle") {
                            if (!viewModel.songs.isEmpty) {
                                viewModel.shufflePlay()
                            }
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
        }
        .onAppear {
            viewModel.fetchSongs()
        }
    }
}

#Preview {
    @Previewable @Namespace var albumViewAnimation
    AlbumTracksView(album: Album(Id: "id", Name: "Name", AlbumArtist: "Artist", AlbumArtists: []))
}

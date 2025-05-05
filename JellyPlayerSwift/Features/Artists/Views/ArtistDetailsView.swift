//
//  ArtistDetailsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

struct ArtistDetailsView: View {
    @State private var viewModel: ViewModel
    
    init(artist: Artist) {
        viewModel = ViewModel(artist: artist)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                ArtistHeader(artist: viewModel.artist)
                    .accessibilityLabel("Artist image")
                    .accessibilityRemoveTraits(.isImage)
                    .frame(maxHeight: proxy.size.height / 1.5)
                
                HStack(spacing: 20) {
                    NiceIconButton("Play", buttonImage: "play.fill") {
                        Task {
                            await viewModel.playArtist()
                        }
                    }
                    .accessibilityHint("Play all songs from this artist")
                    
                    NiceIconButton("Shuffle", buttonImage: "shuffle") {
                        Task {
                            await viewModel.shuffleArtist()
                        }
                    }
                    .accessibilityLabel("Shuffle")
                    .accessibilityHint("Shuffle all songs from this artist")
                }
                .padding()
                
                AlbumsGridView(albums: viewModel.artistAlbums)
            }
        }
        .navigationTitle(viewModel.artist.Name)
        .task {
            viewModel.fetchArtistAlbums()
        }
    }
}

#Preview {
    ArtistDetailsView(artist: Artist(Id: "Id", Name: "Name"))
}

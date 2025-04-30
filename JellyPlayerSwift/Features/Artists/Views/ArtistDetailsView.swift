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
                    .frame(maxHeight: proxy.size.height / 1.5)
                HStack(spacing: 20) {
                    NiceIconButton("Play", buttonImage: "play.fill") {
                        Task {
                            await viewModel.playArtist()
                        }
                    }
                    
                    NiceIconButton("Shuffle", buttonImage: "shuffle") {
                        Task {
                            await viewModel.shuffleArtist()
                        }
                    }
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

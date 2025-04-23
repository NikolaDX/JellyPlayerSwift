//
//  ArtistDetailsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import Kingfisher
import SwiftUI

struct ArtistDetailsView: View {
    @State private var viewModel: ViewModel
    
    init(artist: Artist) {
        viewModel = ViewModel(artist: artist)
    }
    
    var body: some View {
        ScrollView {
            ArtistHeader(artist: viewModel.artist)
            AlbumsGridView(albums: viewModel.artistAlbums)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            viewModel.fetchArtistAlbums()
        }
    }
}

#Preview {
    ArtistDetailsView(artist: Artist(Id: "Id", Name: "Name"))
}

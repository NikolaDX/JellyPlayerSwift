//
//  AlbumsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Kingfisher
import SwiftUI


struct AlbumsView: View {
    @State private var viewModel = ViewModel()
    @State private var size = CGSize.zero
    
    @Namespace var albumViewAnimation

    let columns: [GridItem] = Array.init(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading) {
                    ForEach(viewModel.albums, id: \.Id) { album in
                        NavigationLink {
                            AlbumTracksView(album: album)
                                .navigationTransition(.zoom(sourceID: album.Id, in: albumViewAnimation))
                        } label: {
                            AlbumCard(album: album)
                                .matchedTransitionSource(id: album.Id, in: albumViewAnimation)
                        }
                        .foregroundStyle(.primary)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.fetchAlbums()
        }
    }
}

#Preview {
    AlbumsView()
}

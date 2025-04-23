//
//  AlbumsGridView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

struct AlbumsGridView: View {
    let albums: [Album]
    @Namespace private var albumViewAnimation
    @State private var isDragging: Bool = false
    
    private var albumsByLetter: [String: [Album]] {
        Dictionary(grouping: albums) { album in
            String(album.Name.prefix(1).uppercased())
        }
    }
    
    private var sortedLetters: [String] {
        albumsByLetter.keys.sorted()
    }
    
    var body: some View {
        ScrollView {
            ForEach(sortedLetters, id: \.self) { letter in
                LazyVStack(alignment: .leading) {
                    Section {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                            ForEach(albumsByLetter[letter] ?? [], id: \.Id) { album in
                                NavigationLink {
                                    AlbumTracksView(album: album)
                                        .navigationTransition(.zoom(sourceID: album.Id, in: albumViewAnimation))
                                } label: {
                                    AlbumCard(album: album)
                                        .matchedTransitionSource(id: album.Id, in: albumViewAnimation)
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    } header: {
                        Headline(letter)
                            .padding(.leading)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    AlbumsGridView(albums: [])
}

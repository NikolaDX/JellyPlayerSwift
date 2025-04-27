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
    @State private var filterText: String = ""
    
    private var filteredAlbums: [Album] {
        filterText.isEmpty ? albums: albums.filter {
            $0.Name.localizedCaseInsensitiveContains(filterText) ||
            $0.AlbumArtist.localizedCaseInsensitiveContains(filterText)
        }
    }
    
    private var albumsByLetter: [String: [Album]] {
        Dictionary(grouping: filteredAlbums) { album in
            String(album.Name.prefix(1).uppercased())
        }
    }
    
    private var sortedLetters: [String] {
        albumsByLetter.keys.sorted()
    }
    
    var body: some View {
        ScrollView {
            InputField(text: $filterText, censored: false, placeholder: "Search for an album...")
                .padding()
            
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

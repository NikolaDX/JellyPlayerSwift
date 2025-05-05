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
    @State private var selectedSortOption: String = "Name"
    @State private var selectedSortOrder: String = "Ascending"
    
    private var filteredAlbums: [Album] {
        filterText.isEmpty ? sortedAlbums : sortedAlbums.filter {
            $0.Name.localizedCaseInsensitiveContains(filterText) ||
            $0.AlbumArtist.localizedCaseInsensitiveContains(filterText)
        }
    }
    
    private var sortedAlbums: [Album] {
        let sorted: [Album]
        
        switch selectedSortOption {
        case "Name":
            sorted = albums.sorted { $0.Name < $1.Name }
        case "Artist":
            sorted = albums.sorted { $0.AlbumArtist < $1.AlbumArtist }
        case "DateAdded":
            sorted = albums.sorted { $0.DateCreated ?? "" < $1.DateCreated ?? "" }
        case "DateReleased":
            sorted = albums.sorted { $0.PremiereDate ?? "" < $1.PremiereDate ?? "" }
        default:
            sorted = albums
        }
    
        
        if selectedSortOrder == "Descending" {
            return sorted.reversed()
        } else {
            return sorted
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(filteredAlbums, id: \.Id) { album in
                    NavigationLink {
                        AlbumTracksView(album: album)
                            .navigationTransition(.zoom(sourceID: album.Id, in: albumViewAnimation))
                    } label: {
                        AlbumCard(album: album)
                            .matchedTransitionSource(id: album.Id, in: albumViewAnimation)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Album: \(album.Name) by \(album.AlbumArtist)")
                    .foregroundStyle(.primary)
                    .contextMenu {
                        ContextButton(isDestructive: false, text: "Instant mix", systemImage: "safari") {
                            AlbumService().generateAndPlayInstantMix(albumId: album.Id)
                        }
                        .accessibilityHint("Create mix based on songs from this album")
                        
                        ContextButton(isDestructive: false, text: "Download album", systemImage: "arrow.down.circle") {
                            AlbumService().downloadAlbum(albumId: album.Id)
                        }
                        .accessibilityHint("Download songs from this album for offline listening")
                    }
                }
            }
            .padding()
        }
        .searchable(text: $filterText, prompt: "Search for an album...")
        .toolbar {
            Menu("Sort by", systemImage: "arrow.up.arrow.down") {
                Menu("Sort order") {
                    Picker("Sort order", selection: $selectedSortOrder) {
                        Text("Ascending").tag("Ascending")
                        Text("Descending").tag("Descending")
                    }
                    .accessibilityHint("Select sort order")
                }
                
                Menu("Sort by") {
                    Picker("Sort by", selection: $selectedSortOption) {
                        Text("Name").tag("Name")
                        Text("Artist").tag("Artist")
                        Text("Date added").tag("DateAdded")
                        Text("Date released").tag("DateReleased")
                    }
                    .accessibilityHint("Select sort option")
                }
            }
        }
    }
    
    private func offsetY(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        return minY > 0 ? 0 : -minY
    }
}

#Preview {
    AlbumsGridView(albums: [])
}

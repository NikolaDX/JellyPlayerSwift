//
//  AlbumCover.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct AlbumCover: View {
    private let album: Album
    
    init(album: Album) {
        self.album = album
    }
    
    var body: some View {
        Cover(url: album.coverUrl)
            .clipShape(.rect(cornerRadius: 30))
    }
}

#Preview {
    @Previewable @Namespace var namespace
    AlbumCover(album: Album(Id: "Id", Name: "Name", AlbumArtist: "Artist", AlbumArtists: []))
}

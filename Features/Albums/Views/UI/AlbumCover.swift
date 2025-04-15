//
//  AlbumCover.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Kingfisher
import SwiftUI

struct AlbumCover: View {
    private let album: Album
    
    init(album: Album) {
        self.album = album
    }
    
    var body: some View {
        KFImage(album.coverUrl)
            .resizable()
            .scaledToFit()
            .shadow(color: .primary.opacity(0.5), radius: 5, x: 5, y: 5)
            .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    @Previewable @Namespace var namespace
    AlbumCover(album: Album(Id: "Id", Name: "Name", AlbumArtist: "Artist"))
}

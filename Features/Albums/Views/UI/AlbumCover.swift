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
            .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    @Previewable @Namespace var namespace
    AlbumCover(album: Album(Id: "Id", Name: "Name", AlbumArtist: "Artist"))
}

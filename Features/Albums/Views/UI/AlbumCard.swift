//
//  AlbumCard.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Kingfisher
import SwiftUI

struct AlbumCard: View {
    private var album: Album
    
    init(album: Album) {
        self.album = album
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            AlbumCover(album: album)
                .padding(.bottom, 5)
            
            VStack(alignment: .leading) {
                Text(album.Name)
                    .lineLimit(1)
                    .font(.headline)
                
                Text(album.AlbumArtist)
                    .lineLimit(1)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        
    }
}

#Preview {
    @Previewable @Namespace var albumNamespace
    AlbumCard(album: Album(Id: "id", Name: "Name", AlbumArtist: "Artist"))
}

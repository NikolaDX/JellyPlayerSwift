//
//  AlbumRow.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 11. 8. 2026..
//

import SwiftUI

struct AlbumRow: View {
    private let album: Album
    
    init(_ album: Album) {
        self.album = album
    }
    
    var body: some View {
        HStack {
            AlbumCover(album: album)
                .frame(maxWidth: 50, maxHeight: 50)
            
            VStack(alignment: .leading) {
                Headline(album.Name)
                Subheadline(album.AlbumArtist ?? "Unknown Artist")
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

//#Preview {
//    AlbumRow()
//}

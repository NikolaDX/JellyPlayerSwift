//
//  PlaylistCover.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUI

struct PlaylistCover: View {
    private let playlist: Playlist
    
    init(_ playlist: Playlist) {
        self.playlist = playlist
    }
    
    var body: some View {
        Cover(url: playlist.coverUrl)
            .frame(maxWidth: 50, maxHeight: 50)
            .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    PlaylistCover(Playlist(Id: "Id", Name: "Name"))
}

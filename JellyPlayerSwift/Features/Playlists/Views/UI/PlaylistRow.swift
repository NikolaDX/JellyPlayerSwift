//
//  PlaylistRow.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUI

struct PlaylistRow: View {
    private let playlist: Playlist
    
    init(_ playlist: Playlist) {
        self.playlist = playlist
    }
    
    var body: some View {
        HStack {
            PlaylistCover(playlist)
            
            VStack(alignment: .leading) {
                Headline(playlist.Name)
            }
            
            Spacer()
            
            Subheadline("\(playlist.NumberOfSongs ?? 0) \(playlist.NumberOfSongs == 1 ? "song" : "songs")")
        }
    }
}

#Preview {
    PlaylistRow(Playlist(Id: "Id", Name: "Name"))
}

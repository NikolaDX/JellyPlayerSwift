//
//  PlaylistRow.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUI

struct PlaylistRow: View {
    private let playlist: Playlist
    private let numberOfSongs: Int
    
    init(_ playlist: Playlist) {
        self.playlist = playlist
        self.numberOfSongs = playlist.NumberOfSongs ?? 0
    }
    
    var body: some View {
        HStack {
            PlaylistCover(playlist)
            
            VStack(alignment: .leading) {
                Headline(playlist.Name)
            }
            
            Spacer()
            
            Text("\(numberOfSongs) song")
                .lineLimit(1)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    PlaylistRow(Playlist(Id: "Id", Name: "Name", DateCreated: ""))
}

//
//  AlbumTrackRow.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct AlbumTrackRow: View {
    private var song: Song
    
    init(_ song: Song) {
        self.song = song
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(song.IndexNumber)")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(width: 30)
                
                Text(song.Name)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
            
            Divider()
        }
    }
}

#Preview {
    AlbumTrackRow(Song(Id: "Id", Name: "Name", IndexNumber: 1, Album: "Album", AlbumId: "Id", RunTimeTicks: 12345, Artists: ["Artist"]))
}

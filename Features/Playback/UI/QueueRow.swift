//
//  QueueRow.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/21/25.
//

import SwiftUI

struct QueueRow: View {
    private let song: Song
    private let songIndex: Int
    private let currentIndex: Int
    
    init(song: Song, songIndex: Int, currentIndex: Int) {
        self.song = song
        self.songIndex = songIndex
        self.currentIndex = currentIndex
    }
    
    var body: some View {
        HStack {
            Text("\(songIndex + 1)")
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(song.Name)
                    .lineLimit(1)
                    .font(.headline)
                
                Text(song.Artists.joined(separator: ", "))
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            
            Spacer()
            
            if songIndex == currentIndex {
                Image(systemName: "play.circle.fill")
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    QueueRow(song: Song(Id: "Id", Name: "Name", IndexNumber: 1, Album: "Album", AlbumId: "AlbumId", RunTimeTicks: 120000, Artists: ["Artist"]), songIndex: 1, currentIndex: 1)
}

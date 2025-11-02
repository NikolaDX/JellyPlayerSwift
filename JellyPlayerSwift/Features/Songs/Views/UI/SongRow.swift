//
//  SongRow.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

struct SongRow: View {
    private let song: Song
    
    @State private var showingAddToPlaylist: Bool = false
    
    init(_ song: Song) {
        self.song = song
    }
    
    var body: some View {
        HStack {
            SongCover(song)
            
            VStack(alignment: .leading) {
                Headline(song.Name)
                Subheadline(song.Artists.isEmpty ? "Unknown Artist" : song.Artists.joined(separator: ", "))
            }
            
            Spacer()
            
            Text(formatTime(song.durationInSeconds))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .contentShape(Rectangle())
    }
    
    func formatTime(_ time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    SongRow(Song(Id: "Id", Name: "Name", IndexNumber: 1, Album: "Album", AlbumId: "AlbumId", RunTimeTicks: 120000, Artists: ["Artist"], UserData: UserData(IsFavorite: false, PlayCount: 1), DateCreated: ""))
}

//
//  SongCover.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import SwiftUI

struct SongCover: View {
    private let song: Song
    
    init(_ song: Song) {
        self.song = song
    }
    
    var body: some View {
        Cover(url: song.coverUrl)
            .frame(maxWidth: 50)
            .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    SongCover(Song(Id: "Id", Name: "Name", IndexNumber: 1, Album: "Album", AlbumId: "AlbumId", RunTimeTicks: 120000, Artists: ["Artist"], UserData: UserData(IsFavorite: false)))
}

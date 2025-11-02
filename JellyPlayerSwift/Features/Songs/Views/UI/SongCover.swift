//
//  SongCover.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import Kingfisher
import SwiftUI

struct SongCover: View {
    private let song: Song
    
    init(_ song: Song) {
        self.song = song
    }
    
    var body: some View {
        if let image = song.coverImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 50, maxHeight: 50)
                .clipShape(.rect(cornerRadius: 10))
        } else {
            KFImage(song.coverUrl)
                .placeholder {
                    Image(systemName: "opticaldisc.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 50, maxHeight: 50)
                        .clipShape(.rect(cornerRadius: 10))
                }
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 50, maxHeight: 50)
                .clipShape(.rect(cornerRadius: 10))
        }
    }
}

#Preview {
    SongCover(Song(Id: "Id", Name: "Name", IndexNumber: 1, Album: "Album", AlbumId: "AlbumId", RunTimeTicks: 120000, Artists: ["Artist"], UserData: UserData(IsFavorite: false, PlayCount: 1), DateCreated: ""))
}

//
//  SongsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

struct SongsView: View {
    let songs: [Song]
    
    var body: some View {
        List(songs, id: \.Id) { song in
            Button {
                PlaybackService.shared.playAndBuildQueue(song, songsToPlay: songs)
            } label: {
                SongRow(song)
            }
            .foregroundStyle(.primary)
        }
    }
    
    
}

#Preview {
    SongsView(songs: [])
}

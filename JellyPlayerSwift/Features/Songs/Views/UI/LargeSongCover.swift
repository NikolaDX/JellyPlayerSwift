//
//  LargeSongCover.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import Kingfisher
import SwiftUI

struct LargeSongCover: View {
    private let song: Song
    
    init(_ song: Song) {
        self.song = song
    }
    
    var body: some View {
        if let image = song.coverImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            KFImage(song.coverUrl)
                .placeholder {
                    Image(systemName: "opticaldisc.fill")
                        .resizable()
                        .scaledToFit()
                }
                .resizable()
                .scaledToFit()
        }
    }
}

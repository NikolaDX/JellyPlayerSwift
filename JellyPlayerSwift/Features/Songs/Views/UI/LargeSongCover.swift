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
        KFImage(song.coverUrl)
            .placeholder {
                if let image = song.coverImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
            .resizable()
            .scaledToFit()
    }
}

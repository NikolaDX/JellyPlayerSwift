//
//  ArtistHeader.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import Kingfisher
import SwiftUI

struct ArtistHeader: View {
    private var artist: Artist
    
    let frameHeight: Double = UIDevice.current.userInterfaceIdiom == .pad ? 1.5 : 2.5
    
    init(artist: Artist) {
        self.artist = artist
    }
    
    var body: some View {
        KFImage(artist.coverUrl)
            .resizable()
            .overlay(Color.black.opacity(0.3))
            .stretchy()
            .overlay(ArtistTitleOverlay(artistName: artist.Name), alignment: .bottomLeading)
            .frame(height: UIScreen.main.bounds.height / frameHeight)
    }
}

#Preview {
    ArtistHeader(artist: Artist(Id: "Id", Name: "Name"))
}

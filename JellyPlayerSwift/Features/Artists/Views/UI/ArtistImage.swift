//
//  ArtistImage.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

struct ArtistImage: View {
    private let artist: Artist
    
    init(artist: Artist) {
        self.artist = artist
    }
    
    var body: some View {
        Cover(url: artist.coverUrl)
            .frame(maxWidth: 50)
            .clipShape(.circle)
    }
}

#Preview {
    ArtistImage(artist: Artist(Id: "Id", Name: "Name"))
}

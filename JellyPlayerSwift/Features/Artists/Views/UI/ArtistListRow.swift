//
//  ArtistListRow.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

struct ArtistListRow: View {
    private let artist: Artist
    
    init(artist: Artist) {
        self.artist = artist
    }
    
    var body: some View {
        HStack {
            ArtistImage(artist: artist)
            Headline(artist.Name)
            Spacer()
        }
    }
}

#Preview {
    ArtistListRow(artist: Artist(Id: "Id", Name: "Name"))
}

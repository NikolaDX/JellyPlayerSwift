//
//  ArtistTitleOverlay.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

struct ArtistTitleOverlay: View {
    private var artistName: String
    
    init(artistName: String) {
        self.artistName = artistName
    }
    
    var body: some View {
        Text(artistName)
            .foregroundStyle(.white)
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
            .shadow(color: .black, radius: 10)
    }
}

#Preview {
    ArtistTitleOverlay(artistName: "Artist")
}

//
//  MiniPlayerView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import SwiftUI

struct MiniPlayerView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        if let song = viewModel.currentSong {
            HStack {
                SongCover(song)
                
                VStack(alignment: .leading) {
                    Headline(viewModel.title)
                    Subheadline(viewModel.artist)
                }
                
                Spacer()
                
                ConditionalIconButton(
                    condition: viewModel.isPlaying,
                    trueLabel: Image(systemName: "pause.fill"),
                    falseLabel: Image(systemName: "play.fill")) {
                    viewModel.togglePlayPause()
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 15))
        }
    }
}

#Preview {
    MiniPlayerView()
}

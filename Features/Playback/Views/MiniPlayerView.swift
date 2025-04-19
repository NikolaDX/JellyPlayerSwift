//
//  MiniPlayerView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import SwiftUI

struct MiniPlayerView: View {
    @State private var viewModel = ViewModel()
    
    @Namespace var playerViewAnimation
    
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
                    .font(.title2)
            }
            .padding()
            .sheet(isPresented: $viewModel.showingPlayer) {
                FullMusicPlayerView()
                    .preferredColorScheme(.dark)
                    .navigationTransition(.zoom(sourceID: "playerView", in: playerViewAnimation))
            }
            .matchedTransitionSource(id: "playerView", in: playerViewAnimation)
            .onTapGesture {
                viewModel.showingPlayer = true
            }
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 15))
        }
    }
}

#Preview {
    MiniPlayerView()
}

//
//  MiniPlayerView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import SwiftUI

struct MiniPlayerView: View {
    @State private var viewModel = ViewModel()
    
    @State private var dragOffset: CGFloat = 0
    @Namespace var playerViewAnimation
    
    var body: some View {
        if let song = viewModel.currentSong {
            HStack {
                HStack {
                    SongCover(song)
                    
                    VStack(alignment: .leading) {
                        Headline(viewModel.title)
                        Subheadline(viewModel.artist)
                    }
                }
                .offset(x: dragOffset)
                
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
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height
                        
                        if horizontalAmount < -50 {
                            withAnimation(.easeInOut) {
                                viewModel.nextSong()
                                dragOffset = 0
                            }
                        } else if horizontalAmount > 50 {
                            withAnimation(.easeInOut) {
                                viewModel.previousSong()
                                dragOffset = 0
                            }
                        } else if verticalAmount < -50 {
                            withAnimation(.easeInOut) {
                                viewModel.showingPlayer = true
                                dragOffset = 0
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.25)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
            .sheet(isPresented: $viewModel.showingPlayer) {
                FullMusicPlayerView()
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

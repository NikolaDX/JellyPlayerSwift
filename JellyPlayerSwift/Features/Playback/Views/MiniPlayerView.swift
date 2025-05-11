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
    @State private var verticalDragOffset: CGFloat = 0
    @State private var isDragging = false
    
    @Namespace var playerViewAnimation
    
    private let fullPlayerThreshold: CGFloat = -30
    private let miniPlayerDragLimit: CGFloat = 30
    private let maxDownwardDrag: CGFloat = 20
    
    var body: some View {
        if let song = viewModel.currentSong {
            ZStack(alignment: .bottom) {
                HStack {
                    HStack {
                        SongCover(song)
                        VStack(alignment: .leading) {
                            Headline(viewModel.title)
                            Subheadline(viewModel.artist)
                        }
                    }
                    .accessibilityHidden(true)
                    .offset(x: clamp(dragOffset, lower: -miniPlayerDragLimit, upper: miniPlayerDragLimit))

                    Spacer()
                    
                    if viewModel.playbackService.isLoading {
                        ProgressView()
                            .padding()
                            .accessibilityLabel("Loading...")
                    } else {
                        ConditionalIconButton(
                            condition: viewModel.isPlaying,
                            trueLabel: Image(systemName: "pause.fill"),
                            falseLabel: Image(systemName: "play.fill")) {
                                viewModel.togglePlayPause()
                            }
                            .padding()
                            .font(.title2)
                    }
                }
                .padding(5)
                .contentShape(Rectangle())
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(viewModel.title) by \(viewModel.artist)")
                .accessibilityValue(viewModel.isPlaying ? "Playing" : "Paused")
                .accessibilityHint("Double tap to toggle play-pause. Swipe up to access actions.")
                .accessibilityActions {
                    Button("Next Song") {
                        viewModel.nextSong()
                    }
                    
                    Button("Previous Song") {
                        viewModel.previousSong()
                    }
                    
                    Button("Full Music Player") {
                        viewModel.showingPlayer = true
                    }
                }
                .allowsHitTesting(true)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            dragOffset = value.translation.width
                            verticalDragOffset = value.translation.height
                            isDragging = true
                        }
                        .onEnded { value in
                            isDragging = false
                            
                            let horizontalAmount = value.translation.width
                            let verticalAmount = value.translation.height

                            if abs(horizontalAmount) > abs(verticalAmount) {
                                if horizontalAmount < -50 {
                                    withAnimation(.easeInOut) {
                                        viewModel.nextSong()
                                    }
                                } else if horizontalAmount > 50 {
                                    withAnimation(.easeInOut) {
                                        viewModel.previousSong()
                                    }
                                }
                            } else if verticalAmount < fullPlayerThreshold {
                                dragOffset = 0
                                withAnimation(.spring()) {
                                    viewModel.showingPlayer = true
                                    verticalDragOffset = 0
                                }
                            }
                            
                            withAnimation {
                                dragOffset = 0
                                verticalDragOffset = 0
                            }
                        }
                )
                .contentShape(Rectangle())
            }
            .onTapGesture {
                viewModel.showingPlayer = true
            }
            .sheet(isPresented: $viewModel.showingPlayer) {
                FullMusicPlayerView()
                    .navigationTransition(.zoom(sourceID: "playerView", in: playerViewAnimation))
            }
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 15))
            .matchedTransitionSource(id: "playerView", in: playerViewAnimation)
            .shadow(color: .black.opacity(0.5), radius: 15)
            .scaleEffect(isDragging ? clamp(-verticalDragOffset * 0.5, lower: 1, upper: 1.05) : 1)
            .offset(y: clamp(verticalDragOffset * (verticalDragOffset > 0 ? 0.3 : 0.5), lower: -10, upper: 10))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: verticalDragOffset)
        }
    }
    
    func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }
}

#Preview {
    MiniPlayerView()
}

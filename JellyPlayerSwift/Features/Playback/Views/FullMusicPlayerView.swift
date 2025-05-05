//
//  FullMusicPlayerView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/18/25.
//

import SwiftUI

struct FullMusicPlayerView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var viewModel = ViewModel()
    
    private let buttonSize: Double = 25
    
    var body: some View {
        ZStack {
            GradientView(color: viewModel.coverDominantColor)
            VStack {
                if viewModel.showingQueue {
                    QueueView()
                        .transition(.slide.combined(with: .opacity))
                } else {
                    VStack(spacing: 5) {
                        if let song = viewModel.currentSong {
                            SpinningVinyl(
                                song: song,
                                isPlaying: viewModel.isPlaying,
                                currentTime: $viewModel.sliderTime,
                                isScrubbing: $viewModel.isEditing
                            )
                            .shadow(color: .black, radius: 10)
                        }
                        
                        Spacer()
                        
                        Text(viewModel.title)
                            .font(.title)
                        
                        Text(viewModel.album)
                            .font(.title2)
                        
                        Text(viewModel.artist)
                            .foregroundStyle(.secondary)
                            .font(.title3)
                        
                        Spacer()
                    }
                    .transition(.slide.combined(with: .opacity))
                    .accessibilityHidden(true)
                }
                
                Spacer()
                 
                VStack(spacing: 10) {
                    HStack {
                        Text(viewModel.formattedCurrentTime)
                            .font(.headline)
                            .accessibilityLabel("Current progress: \(viewModel.formattedCurrentTime)")
                        
                        Spacer()
                        
                        Text(viewModel.formattedDuration)
                            .font(.headline)
                            .accessibilityLabel("Song duration: \(viewModel.formattedDuration)")
                    }
                    
                    Slider(value: $viewModel.sliderTime, in: 0...viewModel.duration, onEditingChanged: { editing in
                        if !editing {
                            viewModel.seek(to: viewModel.sliderTime)
                            viewModel.isEditing = false
                        } else {
                            viewModel.isEditing = true
                        }
                    })
                    .onChange(of: viewModel.currentTime) {
                        if !viewModel.isEditing {
                            viewModel.sliderTime = viewModel.currentTime
                        }
                    }
                    .tint(viewModel.coverDominantColor)
                    .accessibilityLabel("Playback position")
                    .accessibilityValue(viewModel.formattedCurrentTime)
                    .accessibilityHint("Swipe up or down with one finger to adjust playback position")
                    .accessibilityAdjustableAction { direction in
                        let step = 5.0
                        switch direction {
                        case .increment:
                            let newTime = min(viewModel.sliderTime + step, viewModel.duration)
                            viewModel.seek(to: newTime)
                            viewModel.sliderTime = newTime
                        case .decrement:
                            let newTime = max(viewModel.sliderTime - step, 0)
                            viewModel.seek(to: newTime)
                            viewModel.sliderTime = newTime
                        default:
                            break
                        }
                    }
                    
                    HStack(alignment: .center, spacing: buttonSize) {
                        IconButton(
                            icon: Image(systemName: "backward.fill")) {
                                viewModel.previousSong()
                            }
                            .accessibilityLabel("Previous song")
                        
                        ConditionalIconButton(
                            condition: viewModel.isPlaying,
                            trueLabel: Image(systemName: "pause.circle.fill"),
                            falseLabel: Image(systemName: "play.circle.fill")) {
                                viewModel.togglePlayPause()
                            }
                            .font(.system(size: buttonSize * 2.2))
                            .accessibilityLabel("Toggle play-pause")
                        
                        IconButton(
                            icon: Image(systemName: "forward.fill")) {
                                viewModel.nextSong()
                            }
                            .accessibilityLabel("Next song")
                    }
                    .font(.system(size: buttonSize))
                    
                    HStack(alignment: .bottom, spacing: buttonSize * 1.2) {
                        ShuffleQueueButton()
                        
                        RepeatModeButton()
                        
                        IconButton(icon: Image(systemName: "chevron.down")) {
                            dismiss()
                        }
                        .accessibilityLabel("Hide full music player")
                        
                        FavoriteButton(isFavorite: viewModel.isFavorite) {
                            viewModel.toggleFavorite()
                        }
                        .accessibilityLabel("Toggle favorite")
                        
                        IconButton(icon: Image(systemName: "music.note.list")) {
                            viewModel.toggleQueue()
                        }
                        .accessibilityLabel("Show queue")
                    }
                    .font(.system(size: buttonSize * 1.2))
                }
            }
            .padding()
            .padding(.vertical, 5)
        }
        .preferredColorScheme(.light)
        .foregroundStyle(.white)
        .onChange(of: viewModel.currentSong) {
            withAnimation {
                viewModel.updateDominantColor()
            }
        }
    }
}

#Preview {
    FullMusicPlayerView()
}

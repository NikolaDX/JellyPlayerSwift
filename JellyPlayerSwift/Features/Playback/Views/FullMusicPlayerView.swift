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
                        SpinningVinyl(
                            coverUrl: viewModel.coverUrl,
                            isPlaying: viewModel.isPlaying,
                            currentTime: $viewModel.sliderTime,
                            isScrubbing: $viewModel.isEditing
                        )
                        .shadow(color: .black, radius: 10)
                        
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
                }
                
                Spacer()
                 
                VStack(spacing: 10) {
                    HStack {
                        Text(viewModel.formattedCurrentTime)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(viewModel.formattedDuration)
                            .font(.headline)
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
                    
                    HStack(alignment: .center, spacing: buttonSize) {
                        IconButton(
                            icon: Image(systemName: "backward.fill")) {
                                viewModel.previousSong()
                            }
                        
                        ConditionalIconButton(
                            condition: viewModel.isPlaying,
                            trueLabel: Image(systemName: "pause.circle.fill"),
                            falseLabel: Image(systemName: "play.circle.fill")) {
                                viewModel.togglePlayPause()
                            }
                            .font(.system(size: buttonSize * 2))
                        
                        IconButton(
                            icon: Image(systemName: "forward.fill")) {
                                viewModel.nextSong()
                            }
                    }
                    .font(.system(size: buttonSize))
                    
                    HStack(alignment: .bottom, spacing: buttonSize * 1.5) {
                        IconButton(icon: Image(systemName: "dice")) {
                            viewModel.shuffleQueue()
                        }
                        
                        RepeatModeButton()
                        
                        IconButton(icon: Image(systemName: "chevron.down")) {
                            dismiss()
                        }
                        
                        FavoriteButton(isFavorite: viewModel.isFavorite) {
                            viewModel.toggleFavorite()
                        }
                        
                        IconButton(icon: Image(systemName: "music.note.list")) {
                            viewModel.toggleQueue()
                        }
                    }
                    .font(.system(size: buttonSize))
                }
            }
            .padding()
            .padding(.vertical, 5)
        }
        .preferredColorScheme(.light)
        .foregroundStyle(.white)
    }
}

#Preview {
    FullMusicPlayerView()
}

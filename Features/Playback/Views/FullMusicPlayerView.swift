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
                Spacer()
                
                if viewModel.showingQueue {
                    VStack {
                        QueueView()
                            
                    }
                    .transition(.slide.combined(with: .opacity))
                    .frame(maxHeight: 500)
                } else {
                    VStack {
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
                    }
                    .transition(.slide.combined(with: .opacity))
                    .frame(maxHeight: 500)
                }
                
                Spacer()
                    
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
                
                HStack(spacing: buttonSize) {
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
                
                Spacer()
                
                HStack(spacing: buttonSize * 1.5) {
                    IconButton(icon: Image(systemName: "dice")) {
                        //shuffle queue
                    }
                    
                    IconButton(icon: Image(systemName: "repeat.circle")) {
                        //change repeat mode
                    }
                    
                    IconButton(icon: Image(systemName: "chevron.down")) {
                        dismiss()
                    }
                    
                    IconButton(icon: Image(systemName: "star")) {
                        //add/remove from favorites
                    }
                    
                    IconButton(icon: Image(systemName: "music.note.list")) {
                        viewModel.toggleQueue()
                    }
                }
                .font(.system(size: buttonSize))
                
                Spacer()
            }
            .padding()
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    FullMusicPlayerView()
}

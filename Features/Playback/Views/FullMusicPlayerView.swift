//
//  FullMusicPlayerView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/18/25.
//

import SwiftUI

struct FullMusicPlayerView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            GradientView(color: viewModel.coverDominantColor)
            
            VStack {
                Spacer()
                
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
                
                Text(viewModel.artist)
                    .font(.title2)
                
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
                
                ConditionalIconButton(
                    condition: viewModel.isPlaying,
                    trueLabel: Image(systemName: "pause.circle.fill"),
                    falseLabel: Image(systemName: "play.circle.fill")) {
                        viewModel.togglePlayPause()
                    }
                    .font(.largeTitle)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    FullMusicPlayerView()
}

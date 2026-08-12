//
//  FullMusicPlayerView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/18/25.
//

import SwiftUI

private enum DragDirection {
   case horizontal, vertical
}

struct FullMusicPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var viewModel = ViewModel()
    @State private var lastHapticTime: Double = 0
    let namespace: Namespace.ID
    
    @State private var dragOffset: CGFloat = 0
    @State private var discDragOffset: CGFloat = 0
    @State private var dragDirection: DragDirection? = nil
    @GestureState private var isDragging = false
    
    private let buttonSize: Double = 25
    private let dismissThreshold: CGFloat = 140
    
    var body: some View {
        ZStack {
            GradientView(color: viewModel.coverDominantColor)
                .matchedGeometryEffect(id: "playerBackground", in: namespace)
            VStack {
                if viewModel.showingQueue {
                    QueueView(accentColor: viewModel.coverDominantColor.readableForeground)
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
                            .matchedGeometryEffect(id: "cover", in: namespace)
                            .shadow(color: .black, radius: 10)
                        }
                        
                        Spacer()
                        
                        Text(viewModel.title)
                            .font(.title)
                            .lineLimit(2)
                        
                        Text(viewModel.album)
                            .font(.title2)
                            .lineLimit(2)
                        
                        Text(viewModel.artist)
                            .foregroundStyle(.secondary)
                            .font(.title3)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                    .transition(.slide.combined(with: .opacity))
                    .accessibilityHidden(true)
                    .offset(x: discDragOffset)
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
                    .tint(viewModel.coverDominantColor.readableForeground)
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
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                viewModel.playbackService.presentation = .mini
                            }
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
            .padding(.vertical, 50)
        }
        .foregroundStyle(viewModel.coverDominantColor.readableForeground)
        .scaleEffect(dragScale, anchor: .top)
        .offset(y: dragOffset)
        .animation(.interactiveSpring(), value: dragCornerRadius)
        .gesture(
            DragGesture(minimumDistance: 10)
                .updating($isDragging) { _, state, _ in state = true }
                .onChanged { value in
                    if dragDirection == nil {
                        dragDirection = abs(value.translation.width) > abs(value.translation.height)
                            ? .horizontal
                            : .vertical
                    }
                    
                    switch dragDirection {
                    case .horizontal:
                        discDragOffset = value.translation.width
                    case .vertical:
                        dragOffset = value.translation.height
                    case nil:
                        break
                    }
                }
                .onEnded { value in
                    switch dragDirection {
                    case .horizontal:
                        let dragAmount = value.translation.width
                        if dragAmount > 50 {
                            withAnimation(.easeInOut) { viewModel.previousSong() }
                        } else if dragAmount < -50 {
                            withAnimation(.easeInOut) { viewModel.nextSong() }
                        }
                        withAnimation(.easeInOut) { discDragOffset = 0 }
                    case .vertical:
                        let dragged = value.translation.height
                        let velocity = value.predictedEndTranslation.height - value.translation.height
                        
                        if dragged > dismissThreshold || velocity > 300 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    viewModel.playbackService.presentation = .mini
                                }
                                
                                dragOffset = 0
                            }
                        } else {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                dragOffset = 0
                            }
                        }
                    case nil:
                        break
                    }
                    
                    dragDirection = nil
                }
        )
        .animation(.interactiveSpring(), value: dragOffset)
        .onChange(of: viewModel.currentSong) {
            withAnimation {
                viewModel.updateDominantColor()
            }
        }
        .onChange(of: viewModel.sliderTime) {
            if (viewModel.isEditing) {
                triggerScrubHaptic()
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase != .active {
                dragOffset = 0
                discDragOffset = 0
                dragDirection = nil
            }
        }
    }
    
    private func triggerScrubHaptic() {
        let interval = 2.0
        guard abs(viewModel.sliderTime - lastHapticTime) >= interval else { return }
        lastHapticTime = viewModel.sliderTime
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private var dragProgress: CGFloat {
        min(dragOffset / dismissThreshold, 1)
    }
    
    private var dragScale: CGFloat {
        1 - (dragProgress * 0.08)
    }
    
    private var dragCornerRadius: CGFloat {
        dragProgress * 100
    }
}

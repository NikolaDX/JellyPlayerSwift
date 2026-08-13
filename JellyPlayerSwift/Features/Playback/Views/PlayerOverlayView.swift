//
//  PlayerOverlayView.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 18. 7. 2026..
//

import SwiftUI

struct PlayerOverlayView: View {
    @State private var playbackService = PlaybackService.shared
    @Namespace private var playerAnimation
    
    @State private var isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    var body: some View {
        ZStack {
            switch playbackService.presentation {
            case .hidden:
                EmptyView()
            case .mini:
                MiniPlayerView(namespace: playerAnimation)
                    .padding()
                    .padding(.bottom, isPad ? iPadPadding : iPhonePadding)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .bottom)),
                            removal: .opacity
                        )
                    )
            case .expanded:
                FullMusicPlayerView(namespace: playerAnimation)
                    .ignoresSafeArea()
                    .transition(
                        .asymmetric(
                            insertion: .opacity,
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: playbackService.presentation)
    }
}

#Preview {
    PlayerOverlayView()
}

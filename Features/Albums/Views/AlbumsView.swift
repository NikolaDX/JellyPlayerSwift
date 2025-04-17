//
//  AlbumsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Kingfisher
import SwiftUI


struct AlbumsView: View {
    @State private var viewModel = ViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var navigationPath = NavigationPath()

    @Namespace private var albumViewAnimation
    
    let columns: [GridItem] = Array.init(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                ForEach(viewModel.albums.indices.reversed(), id: \.self) { index in
                    let album = viewModel.albums[index]
                    let depth = CGFloat(index) - scrollOffset
                    let scale = max(0.7, 1 - abs(depth) * 0.05)
                    let yOffset = -depth * 50
                    let visibleRange: ClosedRange<Int> = Int(scrollOffset)...Int(scrollOffset) + 2
                    let opacity = max(0.3, 1 - abs(depth) * 0.1)

                    GeometryReader { proxy in
                        AlbumCard(album: album)
                            .scaleEffect(scale)
                            .offset(y: yOffset)
                            .zIndex(Double(-depth))
                            .opacity(visibleRange.contains(index) ? opacity : 0)
                            .allowsHitTesting(visibleRange.contains(index))
                            .animation(.easeInOut(duration: 0.3), value: scrollOffset)
                            .onTapGesture {
                                navigationPath.append(album)
                            }
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .matchedTransitionSource(id: album.Id, in: albumViewAnimation)
                    }
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let dragSensitivity: CGFloat = 500
                        let delta = -value.translation.height / dragSensitivity
                        scrollOffset = viewModel.clamp(scrollOffset - delta, lower: 0, upper: CGFloat(viewModel.albums.count - 1))
                    }
            )
        }
        .navigationDestination(for: Album.self) { album in
            AlbumTracksView(album: album)
                .navigationTransition(.zoom(sourceID: album.Id, in: albumViewAnimation))
        }
        .onAppear {
            viewModel.fetchAlbums()
        }
    }
}

#Preview {
    AlbumsView()
}

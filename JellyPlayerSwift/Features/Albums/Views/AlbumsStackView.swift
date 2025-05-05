//
//  AlbumsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Kingfisher
import SwiftUI


struct AlbumsStackView: View {
    @State private var viewModel = ViewModel()
    @State private var scrollOffset: CGFloat = 0
    @Binding var navigationPath: NavigationPath

    @Namespace private var albumViewAnimation
    
    var body: some View {
        VStack {
            GeometryReader { metrics in
                ZStack(alignment: .bottom) {
                    ForEach(viewModel.albums.indices.reversed(), id: \.self) { index in
                        VStack {
                            let screenHeight = metrics.size.height
                            let album = viewModel.albums[index]
                            let depth = CGFloat(index) - scrollOffset
                            let depthScaleFactor = max(0.8, 1 - abs(depth) * 0.1)
                            let scale = (screenHeight / (screenHeight * 1.1)) * depthScaleFactor
                            let yOffset = -depth * (screenHeight / 15)
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
                                    .accessibilityElement(children: .combine)
                                    .accessibilityHidden(index != Int(round(scrollOffset)))
                                    .accessibilityLabel("\(album.Name) by \(album.AlbumArtist)")
                                    .accessibilityAddTraits(.isButton)
                                    .accessibilityHint("Swipe up or down to switch albums. Double tap to open.")
                                    .accessibilityAdjustableAction { direction in
                                        switch direction {
                                        case .increment:
                                            scrollOffset = viewModel.clamp(scrollOffset - 1, lower: 0, upper: CGFloat(viewModel.albums.count - 1))
                                        case .decrement:
                                            scrollOffset = viewModel.clamp(scrollOffset + 1, lower: 0, upper: CGFloat(viewModel.albums.count - 1))
                                        default:
                                            print("Not handled")
                                        }
                                    }
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .matchedTransitionSource(id: album.Id, in: albumViewAnimation)
                            }
                        }
                    }
                }
            }
        }
        .navigationDestination(for: Album.self) { album in
            AlbumTracksView(album: album)
                .navigationTransition(.zoom(sourceID: album.Id, in: albumViewAnimation))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let verticalAmount = value.translation.height
                    if verticalAmount > -20 {
                        scrollOffset = viewModel.clamp(scrollOffset + 1, lower: 0, upper: CGFloat(viewModel.albums.count - 1))
                    } else if verticalAmount < -20 {
                        scrollOffset = viewModel.clamp(scrollOffset - 1, lower: 0, upper: CGFloat(viewModel.albums.count - 1))
                    }
                }
            )
        .onAppear {
            viewModel.fetchAlbums()
        }
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    AlbumsStackView(navigationPath: $navigationPath)
}

//
//  RecommendedSongsCarouselView.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 8. 7. 2026..
//

import SwiftUI

struct RecommendedSongsCarouselView: View {
    @State private var recommendedSongs: [Song] = []
    @State private var isLoading = false
    
    private let rows = [
        GridItem(.fixed(60), spacing: 12),
        GridItem(.fixed(60), spacing: 12),
        GridItem(.fixed(60), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Headline("Recommended For You")
                .padding(.horizontal)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 210)
            } else if recommendedSongs.isEmpty {
                Text("Keep listening! Your personalized recommendations will appear here.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 18) {
                        ForEach(recommendedSongs, id: \.Id) { song in
                            Button {
                                PlaybackService.shared.playAndBuildQueue(song, songsToPlay: recommendedSongs)
                            } label: {
                                SongRow(song)
                                    .frame(width: 290, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 210)
            }
        }
        .task {
            await loadMLRecommendations()
        }
    }
    
    private func loadMLRecommendations() async {
        isLoading = true
        defer { isLoading = false}
        
        let allSongs = await SongsService().fetchAllSongs()
        let modelResults = RecommendationService.shared.getRecommendations(from: allSongs, request: RecommendationRequest.home)
        self.recommendedSongs = Array(modelResults.prefix(12))
    }
}

#Preview {
    RecommendedSongsCarouselView()
}

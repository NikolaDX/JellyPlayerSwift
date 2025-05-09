//
//  ArtistsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

struct ArtistsView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        AsyncView(isLoading: $viewModel.isLoading) {
            List(viewModel.filteredArtists, id: \.Id) { artist in
                NavigationLink(destination: ArtistDetailsView(artist: artist)) {
                    ArtistListRow(artist: artist)
                        .padding(.horizontal)
                        .accessibilityLabel("Artist: \(artist.Name)")
                }
                .foregroundStyle(.primary)
                .contextMenu {
                    ContextButton(isDestructive: false, text: "Instant mix", systemImage: "safari") {
                        viewModel.generateInsantMix(artistId: artist.Id)
                    }
                    .accessibilityHint("Create mix based on songs from this artist")
                }
            }
            .searchable(text: $viewModel.filterText, prompt: "Search for an artist...")
        }
        .navigationTitle("Artists")
        .task {
            viewModel.fetchArtists()
        }
    }
}

#Preview {
    ArtistsView()
}

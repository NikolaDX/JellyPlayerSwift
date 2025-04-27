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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.sortedLetters, id: \.self) { letter in
                    Section(header: Headline(letter).padding(.leading)) {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(viewModel.artistsByLetter[letter] ?? [], id: \.Id) { artist in
                                NavigationLink(destination: ArtistDetailsView(artist: artist)) {
                                    ArtistListRow(artist: artist)
                                        .padding(.horizontal)
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Artists")
        .searchable(text: $viewModel.filterText, prompt: "Search for an artist...")
        .task {
            viewModel.fetchArtists()
        }
    }
}

#Preview {
    ArtistsView()
}

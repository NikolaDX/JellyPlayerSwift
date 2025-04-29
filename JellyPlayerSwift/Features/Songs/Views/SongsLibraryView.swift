//
//  SongsLibraryView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

struct SongsLibraryView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        SongsView(songs: $viewModel.songs)
            .navigationTitle("Songs")
            .task {
                viewModel.fetchSongs()
            }
    }
}

#Preview {
    SongsLibraryView()
}

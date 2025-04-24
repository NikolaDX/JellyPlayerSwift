//
//  DownloadedView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

struct DownloadedView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        SongsView(songs: viewModel.songs)
            .navigationTitle("Downloaded")
            .task {
                viewModel.loadSongs()
            }
    }
}

#Preview {
    DownloadedView()
}

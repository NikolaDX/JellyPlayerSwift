//
//  CreatePlaylistView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUI

struct CreatePlaylistView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = ViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Heading("Playlist name:")
                    .accessibilityHint("Enter new playlist name below")
                
                InputField(text: $viewModel.playlistName, censored: false, placeholder: "Playlist name")
                
                HStack(spacing: 5) {
                    NiceButton("Create playlist") {
                        viewModel.createPlaylist()
                    }
                    .accessibilityHint("Attempt to create new playlist")
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .accessibilityLabel("Creating playlist. Please wait...")
                    }
                }
                
                if let error = viewModel.errorMessage {
                    ErrorText(error)
                        .accessibilityLabel("Error: \(error)")
                }
                
            }
            .padding(20)
        }
        .alert("Playlist creation successful!", isPresented: $viewModel.showingSuccessMessage) {
            Button("Great!", role: .cancel) {
                dismiss()
            }
        }
    }
}

#Preview {
    CreatePlaylistView()
}

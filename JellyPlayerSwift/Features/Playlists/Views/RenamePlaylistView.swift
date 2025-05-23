//
//  RenamePlaylistView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/3/25.
//

import SwiftUI

struct RenamePlaylistView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: ViewModel
    
    init(playlistId: String) {
        viewModel = ViewModel(playlistId: playlistId)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Heading("New playlist name:")
                    .accessibilityHint("Enter new playlist name below")
                
                InputField(text: $viewModel.newPlaylistName, censored: false, placeholder: "Playlist name")
                
                HStack(spacing: 5) {
                    NiceButton("Rename playlist") {
                        viewModel.renamePlaylist()
                    }
                    .accessibilityLabel("Attempt to rename this playlist")
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .accessibilityLabel("Renaming playlist. Please wait...")
                    }
                }
                
                if let error = viewModel.errorMessage {
                    ErrorText(error)
                        .accessibilityLabel("Error: \(error)")
                }
                
            }
            .padding(20)
        }
        .alert("Playlist renaming successful!", isPresented: $viewModel.showingSuccessMessage) {
            Button("Great!", role: .cancel) {
                dismiss()
            }
        }
    }
}

#Preview {
    RenamePlaylistView(playlistId: "Id")
}

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
                
                InputField(text: $viewModel.playlistName, censored: false, placeholder: "Playlist name")
                
                HStack(spacing: 5) {
                    NiceButton("Create playlist") {
                        viewModel.createPlaylist()
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
                
                if let error = viewModel.errorMessage {
                    ErrorText(error)
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

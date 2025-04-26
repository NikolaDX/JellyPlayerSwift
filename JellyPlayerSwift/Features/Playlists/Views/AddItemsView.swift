//
//  AddItems.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/26/25.
//

import SwiftUI

struct AddItemsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var viewModel: ViewModel
    @State private var editMode: EditMode = .active
    @State private var songsSelection = Set<String>()
    
    init(playlistId: String, refreshAction: @escaping () -> Void) {
        viewModel = ViewModel(playlistId: playlistId, refreshAction: refreshAction)
    }
    
    var body: some View {
        NavigationStack {
            List(viewModel.songs, id: \.Id, selection: $songsSelection) { song in
                SongRow(song)
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Add songs")
            .toolbar {
                Button("Done") {
                    viewModel.addSongsToPlaylist(songIds: Array(songsSelection))
                    dismiss()
                }
            }
        }
        
        .task {
            viewModel.fetchAllSongs()
        }
    }
}

#Preview {
    AddItemsView(playlistId: "Id") {
        
    }
}

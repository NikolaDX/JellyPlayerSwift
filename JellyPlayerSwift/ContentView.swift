//
//  ContentView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            AlbumsView()
                .navigationTitle("JellyPlayer")
                .toolbar {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
        }
        .padding(.bottom, PlaybackService.shared.currentSong == nil ? 0 : 100)
        .overlay(alignment: .bottom) {
            MiniPlayerView()
                .padding()
        }
    }
}

#Preview {
    ContentView()
}

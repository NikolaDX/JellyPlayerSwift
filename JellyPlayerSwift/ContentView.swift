//
//  ContentView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        DownloadProgressView(downloadService: DownloadService.shared)
        TabsScreen()
        .safeAreaInset(edge: .bottom) {
            VStack {
                MiniPlayerView()
                    .padding()
                    .padding(.bottom,
                             UIDevice.current.userInterfaceIdiom == .pad
                             ? 0 : 55
                    )
            }
        }
    }
}

#Preview {
    ContentView()
}

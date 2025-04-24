//
//  TabView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/22/25.
//

import SwiftUI

struct TabsScreen: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                AlbumsView()
                    .modifier(MiniPlayerModifier())
            }
            
            Tab("Library", systemImage: "music.note") {
                LibraryView()
                    .modifier(MiniPlayerModifier())
            }
            
            Tab("Settings", systemImage: "gear") {
                SettingsView()
                    .modifier(MiniPlayerModifier())
            }
        }
        
        if DownloadService.shared.isDownloading {
            ProgressView(value: DownloadService.shared.averageDownloadProgress, total: 1.0)
        }
    }
}

#Preview {
    TabsScreen()
}

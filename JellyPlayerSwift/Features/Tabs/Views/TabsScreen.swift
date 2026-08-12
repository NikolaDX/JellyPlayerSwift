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
                HomeScreenView()
            }
            
            Tab("Library", systemImage: "music.note") {
                LibraryView()
            }
            
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
            
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        }
    }
}

#Preview {
    TabsScreen()
}

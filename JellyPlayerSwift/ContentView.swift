//
//  ContentView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var themeService = ThemeService()
    @StateObject var languageService = LanguageService()
    let playbackService = PlaybackService.shared
    
    var body: some View {
        Group {
            AppMainView()
        }
        .id(languageService.selectedLanguage)
        .preferredColorScheme(
            themeService.selectedMode == .system ? nil :
                (themeService.selectedMode == .light ? .light : .dark)
        )
        .tint(themeService.selectedAccentColor)
        .environmentObject(themeService)
        .environmentObject(languageService)
        .environment(\.locale, Locale(identifier: languageService.selectedLanguage.rawValue))
        .environment(\.layoutDirection, languageService.selectedLanguage == .arabic ? .rightToLeft : .leftToRight)
        .task {
            await LibraryService.shared.loadAll(forceRefresh: true)
        }
    }
}

struct AppMainView: View {
    var body: some View {
        Group {
            DownloadProgressView()
            ZStack(alignment: .bottom) {
                TabsScreen()
                PlayerOverlayView()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
        }
    }
}

#Preview {
    ContentView()
}

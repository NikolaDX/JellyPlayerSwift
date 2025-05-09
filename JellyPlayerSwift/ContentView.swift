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
        .overlay {
            if playbackService.isLoading {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Loading...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .accessibilityLabel("Loading...")
                }
                .transition(.opacity)
                .animation(.easeInOut, value: playbackService.isLoading)
            }
        }
        .tint(themeService.selectedAccentColor)
        .environmentObject(themeService)
        .environmentObject(languageService)
        .environment(\.locale, Locale(identifier: languageService.selectedLanguage.rawValue))
        .environment(\.layoutDirection, languageService.selectedLanguage == .arabic ? .rightToLeft : .leftToRight)
    }
}

struct AppMainView: View {
    var body: some View {
        Group {
            DownloadProgressView()
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
}

#Preview {
    ContentView()
}

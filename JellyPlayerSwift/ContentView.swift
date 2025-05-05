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

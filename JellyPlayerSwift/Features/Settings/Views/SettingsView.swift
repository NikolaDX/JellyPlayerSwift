//
//  SettingsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var languageService: LanguageService
    @State private var viewModel = ViewModel()
    @StateObject private var streamQualityService = StreamQualityService.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Heading("Server setup")
                    InputField(text: $viewModel.serverText, censored: false, placeholder: "Server URL")
                    NiceButton("Set server") {
                        Task { @MainActor in
                            await viewModel.setServerProcedure()
                        }
                    }
                    
                    Heading("Appearance")
                    
                    Headline("App theme")
                    Picker("App theme", selection: $themeService.selectedMode) {
                        ForEach(ThemeMode.allCases) { mode in
                            Text(LocalizedStringKey(mode.rawValue.capitalized)).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Headline("Accent color")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(themeService.availableAccentColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: themeService.selectedAccentColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    themeService.selectedAccentColor = color
                                }
                        }
                        
                        ColorPicker("Custom color", selection: $themeService.selectedAccentColor, supportsOpacity: false)
                            .labelsHidden()
                    }
                    
                    Heading("Stream quality")
                    
                    Headline("Wi-Fi quality")
                    Picker("Wi-Fi quality", selection: $streamQualityService.selectedWifiQuality) {
                        ForEach(streamQualityService.availableQualityOptions, id: \.self) { quality in
                            Text("\(quality) kbps").tag(quality)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Headline("Cellular quality")
                    Picker("Cellular quality", selection: $streamQualityService.selectedCellularQuality) {
                        ForEach(streamQualityService.availableQualityOptions, id: \.self) { quality in
                            Text("\(quality) kbps").tag(quality)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Heading("Language")
                    
                    Picker("Language", selection: $languageService.selectedLanguage) {
                        ForEach(Language.allCases) { language in
                            Text(LocalizedStringKey(language.localizedName)).tag(language)
                        }
                    }
                    
                }
                .navigationTitle("Settings")
                .sheet(isPresented: $viewModel.showingLogin) {
                    AuthenticationView(serverUrl: viewModel.serverText)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
                .alert("Server invalid", isPresented: $viewModel.showingServerInvalid) {
                    Button("Ok") { }
                } message: {
                    Text("The URL you provided is not a valid Jellyfin server URL.")
                }
                .padding(20)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

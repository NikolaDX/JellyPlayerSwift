//
//  SettingsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeService: ThemeService
    @State private var viewModel = ViewModel()
    
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
                            Text(mode.rawValue.capitalized).tag(mode)
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
                            .padding(.top, 10)
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

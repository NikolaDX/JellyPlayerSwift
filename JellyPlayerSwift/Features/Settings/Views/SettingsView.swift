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
    
    @AppStorage(locationEnabled) private var locationTrackingEnabled = true
    @AppStorage(motionEnabled) private var motionTrackingEnabled = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Heading("Server setup")
                        .accessibilityHint("Enter your server URL below")
                    InputField(text: $viewModel.serverText, censored: false, placeholder: "Server URL")
                    NiceButton("Set server") {
                        Task { @MainActor in
                            await viewModel.setServerProcedure()
                        }
                    }
                    .accessibilityLabel("Set server")
                    .accessibilityHint("Log into server")
                    
                    Heading("Appearance")
                        .accessibilityHint("Configure app theme and accent color below")
                    
                    Headline("App theme")
                        .accessibilityHint("Select app theme below")
                    
                    Picker("App theme", selection: $themeService.selectedMode) {
                        ForEach(ThemeMode.allCases) { mode in
                            Text(LocalizedStringKey(mode.rawValue.capitalized)).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Headline("Accent color")
                        .accessibilityHint("Select an accent color")
                    
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
                                .accessibilityLabel("Color: \(color.description)")
                                .accessibilityHint("Double-tap to select this color")
                                .accessibilityAddTraits(.isButton)
                                .accessibilityAddTraits(themeService.selectedAccentColor == color ? .isSelected : [])
                        }
                        
                        ColorPicker("Custom color", selection: $themeService.selectedAccentColor, supportsOpacity: false)
                            .labelsHidden()
                    }
                    
                    Heading("Stream quality")
                        .accessibilityHint("Configure stream quality for Wi-Fi and cellular below")
                    
                    Headline("Wi-Fi quality")
                        .accessibilityHint("Select your preferred Wi-Fi streaming quality")
                    
                    Picker("Wi-Fi quality", selection: $streamQualityService.selectedWifiQuality) {
                        ForEach(streamQualityService.availableQualityOptions, id: \.self) { quality in
                            if quality == "Max" {
                                Text("Max").tag(quality)
                            } else {
                                Text("\(quality) kbps").tag(quality)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Headline("Cellular quality")
                        .accessibilityHint("Select your preferred cellular streaming quality")
                    
                    Picker("Cellular quality", selection: $streamQualityService.selectedCellularQuality) {
                        ForEach(streamQualityService.availableQualityOptions, id: \.self) { quality in
                            if quality == "Max" {
                                Text("Max").tag(quality)
                            } else {
                                Text("\(quality) kbps").tag(quality)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Heading("Privacy")
                        .accessibilityHint("Toggle privacy settings")
                    
                    Toggle("Location tracking", isOn: $locationTrackingEnabled)
                        .onChange(of: locationTrackingEnabled) {
                            LocationService.shared.setEnabled(locationTrackingEnabled)
                        }
                        .accessibilityLabel("Location tracking")
                        .accessibilityValue( locationTrackingEnabled ? "On" : "Off" )
                        .accessibilityHint("Allow JellyPlayer to use your location for personalized music recommendations")
                    
                    Toggle("Motion & activity tracking", isOn: $motionTrackingEnabled)
                        .onChange(of: motionTrackingEnabled) { MotionService.shared.setEnabled( motionTrackingEnabled ) }
                        .accessibilityLabel("Motion and activity tracking") .accessibilityValue( motionTrackingEnabled ? "On" : "Off" )
                        .accessibilityHint("Allow JellyPlayer to use your activity for personalized music recommendations")
                    
                    Text( "Location and motion data are used to improve personalized music recommendations. Turning these options off stops JellyPlayer from using them for personalization." )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Privacy information. Location and motion data are used to improve personalized music recommendations. Turning these options off stops JellyPlayer from using them for personalization.")

                    Heading("Language")
                        .accessibilityHint("Select the app language below")
                    
                    Picker("Language", selection: $languageService.selectedLanguage) {
                        ForEach(Language.allCases) { language in
                            Text(LocalizedStringKey(language.localizedName)).tag(language)
                        }
                        .accessibilityHint("Select language for this app")
                    }
                    
                    #if DEBUG
                    
                    Heading("Developer")
                    
                    NiceButton("Compare Recommendation Models") {
                        Task(priority: .background) {
                            let history = HistoryService.shared.fetchLocalHistory()
                            _ = ModelEvaluationService.shared.compareAlgorithms(history: history)
                        }
                    }
                    
                    #endif
                    
                }
                .padding(.bottom, CGFloat(PlaybackService.shared.presentation == .hidden ? 0 : miniPlayerPadding))
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

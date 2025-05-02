//
//  SettingsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct SettingsView: View {
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

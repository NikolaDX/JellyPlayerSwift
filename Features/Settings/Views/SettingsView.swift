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
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Heading("Server setup")
                InputField(text: $viewModel.serverText, censored: false, placeholder: "Server URL")
                
                NiceButton("Set server") {
                    viewModel.showingLogin = true
                }
                
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $viewModel.showingLogin) {
                AuthenticationView(serverUrl: viewModel.serverText)
            }
            .padding(20)
        }
    }
}

#Preview {
    SettingsView()
}

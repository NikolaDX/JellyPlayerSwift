//
//  AuthenticationView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct AuthenticationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: ViewModel
    
    init(serverUrl: String) {
        self.viewModel = ViewModel(serverUrl: serverUrl)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Heading("Username:")
                    .accessibilityHint("Enter your username below")
                
                InputField(text: $viewModel.username, censored: false, placeholder: "Username")
                
                Heading("Password:")
                    .accessibilityHint("Enter your password below")
                
                InputField(text: $viewModel.password, censored: true, placeholder: "Password")
                
                HStack(spacing: 5) {
                    NiceButton("Log in") {
                        Task {
                            await viewModel.logIn()
                        }
                    }
                    .accessibilityHint("Attempt to log into server")
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .accessibilityLabel("Logging in. Please wait...")
                    }
                }
                
                if let error = viewModel.errorMessage {
                    ErrorText(error)
                        .accessibilityLabel("Error: \(error)")
                }
                
            }
            .padding(20)
        }
        .alert("Login successful!", isPresented: $viewModel.showingSuccessMessage) {
            Button("Great!", role: .cancel) {
                dismiss()
            }
        }
    }
}

#Preview {
    AuthenticationView(serverUrl: "http://:8096")
}

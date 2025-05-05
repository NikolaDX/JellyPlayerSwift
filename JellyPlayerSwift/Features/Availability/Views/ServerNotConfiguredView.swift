//
//  ServerNotConfiguredView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/2/25.
//

import SwiftUI

struct ServerNotConfiguredView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Server not configured", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text("Configure server from the settings menu.")
        } actions: {
            NavigationLink {
                SettingsView()
            } label: {
                Text("Settings")
                    .foregroundStyle(.blue)
                    .padding(15)
                    .padding(.horizontal, 20)
                    .background(.secondary.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 10))
            }
            .accessibilityHint("Head to the settings page")
            .foregroundStyle(.primary)
        }
    }
}

#Preview {
    ServerNotConfiguredView()
}

//
//  NetworkUnavailableView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/2/25.
//

import SwiftUI

struct NetworkUnavailableView: View {
    var body: some View {
        ContentUnavailableView {
            Label("You are offline", systemImage: "wifi.slash")
        } description: {
            Text("Connect to the internet, or listen to downloaded music.")
        } actions: {
            NavigationLink {
                DownloadedView()
            } label: {
                Text("Downloaded")
                    .foregroundStyle(.blue)
                    .padding(15)
                    .padding(.horizontal, 20)
                    .background(.secondary.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 10))
            }
            .accessibilityHint("Head to the downloads page")
            .foregroundStyle(.primary)
        }
    }
}

#Preview {
    NetworkUnavailableView()
}

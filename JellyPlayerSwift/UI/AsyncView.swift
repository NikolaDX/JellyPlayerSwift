//
//  AsyncView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/9/25.
//

import SwiftUI

struct AsyncView<Content: View>: View {
    var isLoading: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        let _ = print("PlaylistsView recomputed")
        
        Group {
            if isLoading {
                ProgressView()
                    .accessibilityLabel("Loading...")
            } else {
                content
                    .transition(.slide.combined(with: .opacity))
            }
        }
        .animation(.default, value: isLoading)
    }
}

#Preview {
    AsyncView(isLoading: true) {
        Text("AsyncView")
    }
}

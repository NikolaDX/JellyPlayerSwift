//
//  AsyncView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/9/25.
//

import SwiftUI

struct AsyncView<Content: View>: View {
    @Binding var isLoading: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        if isLoading {
            ProgressView()
                .accessibilityLabel("Loading...")
        } else {
            content
                .transition(.slide.combined(with: .opacity))
        }
    }
}

#Preview {
    @Previewable @State var isLoading: Bool = false
    AsyncView(isLoading: $isLoading) {
        Text("AsyncView")
    }
}

//
//  ContextButton.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/28/25.
//

import SwiftUI

struct ContextButton: View {
    private let isDestructive: Bool
    private let text: String
    private let systemImage: String
    private let action: () -> Void
    
    init(isDestructive: Bool, text: String, systemImage: String, action: @escaping () -> Void) {
        self.isDestructive = isDestructive
        self.text = text
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button(role: isDestructive ? .destructive : .cancel) {
            action()
        } label: {
            Label(text, systemImage: systemImage)
        }
    }
}

#Preview {
    ContextButton(isDestructive: false, text: "Button", systemImage: "play.fill") {
        
    }
}

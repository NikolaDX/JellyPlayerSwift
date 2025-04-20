//
//  IconButton.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/20/25.
//

import SwiftUI

struct IconButton: View {
    private var icon: Image
    private var action: () -> Void
    
    init(icon: Image, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            icon
        }
    }
}

#Preview {
    IconButton(icon: Image(systemName: "play.circle.fill")) { }
}

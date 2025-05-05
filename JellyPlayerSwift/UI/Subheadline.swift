//
//  Subheadline.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import SwiftUI

struct Subheadline: View {
    private var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(LocalizedStringKey(text))
            .lineLimit(1)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    Subheadline("Subheadline")
}

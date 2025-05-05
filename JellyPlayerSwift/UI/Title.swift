//
//  Title.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

struct Title: View {
    private var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(LocalizedStringKey(text))
            .font(.largeTitle)
            .fontWeight(.bold)
    }
}

#Preview {
    Title("Title")
}

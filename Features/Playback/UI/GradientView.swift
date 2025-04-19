//
//  GradientView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/19/25.
//

import SwiftUI

struct GradientView: View {
    private var color: Color
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        LinearGradient(
           gradient: Gradient(colors: [color, color.opacity(0.5)]),
           startPoint: .bottomTrailing,
           endPoint: .topLeading
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: color)
    }
}

#Preview {
    GradientView(color: .blue)
}

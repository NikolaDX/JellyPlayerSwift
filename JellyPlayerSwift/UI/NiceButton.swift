//
//  NiceButton.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct NiceButton: View {
    @EnvironmentObject private var themeService: ThemeService
    private var buttonAction: () -> Void
    private var buttonLabel: String
    
    init(_ buttonLabel: String, buttonAction: @escaping () -> Void) {
        self.buttonLabel = buttonLabel
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            Text(LocalizedStringKey(buttonLabel))
                .foregroundStyle(themeService.selectedAccentColor)
                .padding(15)
                .padding(.horizontal, 20)
                .background(.secondary.opacity(0.2))
                .clipShape(.rect(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NiceButton("Click me") {
        
    }
}

//
//  NiceIconButton.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct NiceIconButton: View {
    @EnvironmentObject private var themeService: ThemeService
    private var buttonAction: () -> Void
    private var buttonLabel: String
    private var buttonImage: String
    
    init(_ buttonLabel: String, buttonImage: String, buttonAction: @escaping () -> Void) {
        self.buttonLabel = buttonLabel
        self.buttonImage = buttonImage
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            Label(LocalizedStringKey(buttonLabel), systemImage: buttonImage)
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
    NiceIconButton("Play", buttonImage: "play.fill") {
        
    }
}

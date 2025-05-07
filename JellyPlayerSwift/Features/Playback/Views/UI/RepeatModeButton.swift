//
//  RepeatModeButton.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/21/25.
//

import SwiftUI

struct RepeatModeButton: View {
    @State private var repeatMode = PlaybackService.shared.getRepeatMode()
    
    var body: some View {
        buttonView
            .id(repeatMode)
    }
    
    var buttonView: some View {
        Button {
            changeRepeatMode()
        } label: {
            switch repeatMode {
            case .none:
                Image(systemName: "repeat.circle")
            case .repeatAll:
                Image(systemName: "repeat.circle.fill")
            case .repeatOne:
                Image(systemName: "repeat.1.circle.fill")
            }
        }
        .accessibilityLabel("Repeat mode")
        .accessibilityValue(repeatMode.accessibilityLabelKey)
    }
    
    func changeRepeatMode() {
        PlaybackService.shared.changeQueueMode()
        repeatMode = PlaybackService.shared.getRepeatMode()
    }
}

#Preview {
    RepeatModeButton()
}

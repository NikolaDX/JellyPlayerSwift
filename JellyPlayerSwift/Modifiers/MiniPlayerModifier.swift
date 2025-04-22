//
//  MiniPlayerModifier.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/22/25.
//

import SwiftUI

struct MiniPlayerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.bottom,
                     PlaybackService.shared.currentSong != nil
                     ? 75 : 0)
    }
}

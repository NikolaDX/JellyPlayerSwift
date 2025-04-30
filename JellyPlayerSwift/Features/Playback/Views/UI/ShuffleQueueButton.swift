//
//  ShuffleQueueButton.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/30/25.
//

import SwiftUI

struct ShuffleQueueButton: View {
    @State private var queueShuffled = PlaybackService.shared.getQueueShuffled()
    
    var body: some View {
        Button {
            withAnimation {
                shuffleQueue()
            }
        } label: {
            if queueShuffled {
                Image(systemName: "shuffle.circle.fill")
            } else {
                Image(systemName: "shuffle.circle")
            }
        }
    }
    
    func shuffleQueue() {
        PlaybackService.shared.shuffleQueue()
        queueShuffled = PlaybackService.shared.getQueueShuffled()
    }
}

#Preview {
    ShuffleQueueButton()
}

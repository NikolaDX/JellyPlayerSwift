//
//  QueueView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/20/25.
//

import Foundation

extension QueueView {
    @Observable
    class ViewModel {
        var queue: [Song] {
            PlaybackService.shared.getQueue()
        }
        
        var currentIndex: Int {
            PlaybackService.shared.getCurrentIndex()
        }
        
        var coverUrl: URL? {
            queue[currentIndex].coverUrl
        }
       
        var songName: String {
            queue[currentIndex].Name
        }
        
        var songArtists: String {
            queue[currentIndex].Artists.joined(separator: ", ")
        }
        
    }
}

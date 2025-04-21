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
        let playbackService = PlaybackService.shared
        
        var queue: [Song] {
            playbackService.getQueue()
        }
        
        var currentIndex: Int {
            playbackService.getCurrentIndex()
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
        
        func playSong(songIndex: Int) {
            playbackService.playAtIndex(songIndex)
        }
        
        func removeAtIndexes(_ indexSet: IndexSet) {
            for index in indexSet {
                playbackService.removeFromQueue(at: index)
            }
        }
        
        func moveQueueItems(from indexes: IndexSet, to destination: Int) {
            playbackService.moveSong(from: indexes, to: destination)
        }
    }
}

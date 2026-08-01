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
        
        var isLoadingRecommendations = false
        var recommendationError: RecommendationError?
        
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
        
        func removeFromQueue(index: Int) {
            playbackService.removeFromQueue(at: index)
        }
        
        func removeAtIndexes(_ indexSet: IndexSet) {
            for index in indexSet {
                playbackService.removeFromQueue(at: index)
            }
        }
        
        func moveQueueItems(from indexes: IndexSet, to destination: Int) {
            playbackService.moveSong(from: indexes, to: destination)
        }
        
        func addRecommended() async {
            isLoadingRecommendations = true
            recommendationError = nil
            
            defer {
                isLoadingRecommendations = false
            }
            
            do {
                let allSongs = await SongsService().fetchAllSongs()
                let recommendations = try RecommendationService.shared.getRecommendations(
                    from: allSongs,
                    request: .queue(queue: queue)
                )
                playbackService.addToQueue(songs: Array(recommendations.prefix(10)))
            } catch let error as RecommendationError {
                recommendationError = error
            }  catch {
                recommendationError = .recommendationFailed
            }
        }
    }
}

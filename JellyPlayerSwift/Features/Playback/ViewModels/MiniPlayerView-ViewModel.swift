//
//  MiniPlayerView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import Foundation
import SwiftUI

extension MiniPlayerView {
    @Observable
    class ViewModel {
        var playbackService = PlaybackService.shared
        var showingPlayer: Bool = false
        
        var currentSong: Song? {
            playbackService.currentSong
        }
        
        var coverUrl: URL? {
            playbackService.currentSong?.coverUrl
        }
        
        var title: String {
            playbackService.currentSong?.Name ?? ""
        }
        
        var artist: String {
            if let song = playbackService.currentSong {
                return song.Artists.isEmpty ? "Unkown Artist" : song.Artists.joined(separator: ", ")
            } else  {
                return "Unknown Artist"
            }
        }
        
        var isPlaying: Bool {
            playbackService.isPlaying
        }
        
        func togglePlayPause() {
            playbackService.togglePlayPause()
        }
        
        func nextSong() {
            playbackService.next()
        }
        
        func previousSong() {
            playbackService.previous()
        }
    }
}

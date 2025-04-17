//
//  MiniPlayerView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import Foundation
import SwiftAudioEx
import SwiftUI

extension MiniPlayerView {
    @Observable
    class ViewModel {
        var playbackService = PlaybackService.shared
        
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
            playbackService.currentSong?.Artists.joined(separator: ", ") ?? ""
        }
        
        var isPlaying: Bool {
            playbackService.isPlaying
        }
        
        func togglePlayPause() {
            playbackService.togglePlayPause()
        }
    }
}

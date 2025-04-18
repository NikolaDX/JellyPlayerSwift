//
//  FullMusicPlayerView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/18/25.
//

import Foundation

extension FullMusicPlayerView {
    @Observable
    class ViewModel {
        var playbackService = PlaybackService.shared
        var sliderTime: Double = 0
        var isEditing: Bool = false
        
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
        
        var duration: Double {
            playbackService.duration
        }
        
        var formattedDuration: String {
            formatTime(duration)
        }
        
        var currentTime: Double {
            playbackService.currentTime
        }
        
        var formattedCurrentTime: String {
            formatTime(sliderTime)
        }
        
        func togglePlayPause() {
            playbackService.togglePlayPause()
        }
        
        func seek(to time: Double) {
            playbackService.seek(to: time)
        }
        
        init() {
            sliderTime = currentTime
        }
        
        func formatTime(_ time: Double) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

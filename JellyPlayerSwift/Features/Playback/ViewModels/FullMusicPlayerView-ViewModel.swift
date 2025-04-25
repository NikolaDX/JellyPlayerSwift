//
//  FullMusicPlayerView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/18/25.
//

import Foundation
import SwiftUI

extension FullMusicPlayerView {
    @Observable
    class ViewModel {
        var playbackService = PlaybackService.shared
        var sliderTime: Double = 0
        var isEditing: Bool = false
        var coverDominantColor: Color = .black
        var showingQueue: Bool = false
        
        var currentSong: Song? {
            playbackService.currentSong
        }
        
        var coverUrl: URL? {
            playbackService.currentSong?.coverUrl
        }
        
        var isFavorite: Bool {
            playbackService.currentSong?.UserData.IsFavorite ?? false
        }
        
        func updateDominantColor() {
            if let image = currentSong?.coverImage {
                coverDominantColor = image.dominantColor()
            } else {
                guard let url = coverUrl else { return }
                
                ArtworkService().fetchArtwork(url: url) { [weak self] image in
                    guard let self = self, let image = image else { return }
                    self.coverDominantColor = image.dominantColor()
                }
            }
        }
        
        var title: String {
            playbackService.currentSong?.Name ?? ""
        }
        
        var artist: String {
            playbackService.currentSong?.Artists.joined(separator: ", ") ?? ""
        }
        
        var album: String {
            playbackService.currentSong?.Album ?? ""
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
        
        init() {
            sliderTime = currentTime
            updateDominantColor()
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
        
        func seek(to time: Double) {
            playbackService.seek(to: time)
        }
        
        func toggleQueue() {
            withAnimation {
                showingQueue.toggle()
            }
        }
        
        func shuffleQueue() {
            withAnimation {
                playbackService.shuffleQueue()
            }
        }
        
        func toggleFavorite() {
            if let song = currentSong {
                let favoritesService = FavoritesService()
                if song.UserData.IsFavorite {
                    favoritesService.removeFromFavorites(song: song)
                } else {
                    favoritesService.addSongToFavorites(song: song)
                }
            }
        }
        
        func formatTime(_ time: Double) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

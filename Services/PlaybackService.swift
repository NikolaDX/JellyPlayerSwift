//
//  PlaybackService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import AVFoundation
import Foundation

@Observable
class PlaybackService {
    static let shared = PlaybackService()
    
    private var player: AVPlayer?
    
    var currentSong: Song? = nil
    var isPlaying: Bool = false
    
    private init() { }
    
    func playSong(_ song: Song) throws {
        let playerItem = AVPlayerItem(url: song.streamUrl!)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        currentSong = song
        isPlaying = true
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            if let _ = currentSong {
                player?.play()
                isPlaying = true
            }
        }
    }
}

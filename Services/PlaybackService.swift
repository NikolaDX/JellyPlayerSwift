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
    private var timeObserverToken: Any?
    
    var currentSong: Song? = nil
    var isPlaying: Bool = false
    
    var currentTime: Double = 0
    
    var duration: Double {
        if let time = self.player?.currentItem?.duration.seconds {
            if !time.isNaN && time.isFinite {
                return time
            }
        }
        return 0
    }
    
    private init() { }
    
    deinit {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
    }
    
    func playSong(_ song: Song) throws {
        let playerItem = AVPlayerItem(url: song.streamUrl!)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        let interval = CMTimeMakeWithSeconds(1.0, preferredTimescale: 1)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateTime()
        }
        currentSong = song
        isPlaying = true
    }

    func updateTime() {
        if let time = self.player?.currentTime().seconds {
            if !time.isNaN && time.isFinite {
                currentTime = time
            }
        } else {
            currentTime = 0
        }
    }
    
    func togglePlayPause() {
        isPlaying ? player?.pause() : player?.play()
        isPlaying.toggle()
    }
    
    func seek(to time: Double) {
        self.player?.seek(to: CMTimeMakeWithSeconds(time, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
    }
}

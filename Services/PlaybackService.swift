//
//  PlaybackService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import AVFoundation
import Combine
import Foundation
import MediaPlayer

@Observable
class PlaybackService {
    static let shared = PlaybackService()
    
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var playbackObserverToken: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var queue: [Song] = []
    private var currentIndex: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private init() {
        setupBackgroundSession()
        setupRemoteControls()
        setupAutomaticPlayback()
    }
    
    deinit {
        cleanup()
    }
    
    func setupBackgroundSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setupAutomaticPlayback() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] _ in
                self?.next()
            }
            .store(in: &cancellables)
    }
    
    func updateNowPlayingInfo(song: Song) {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: song.Name,
            MPMediaItemPropertyArtist: song.Artists.joined(separator: ", "),
            MPMediaItemPropertyAlbumTitle: song.Album,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
        ]
        
        let artworkService = ArtworkService()
        
        artworkService.fetchArtwork(url: song.coverUrl!) { image in
            if let img = image {
                let artwork = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }

        playbackObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let _ = self else { return }

            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(time)
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    func setupRemoteControls() {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        
        remoteCommandCenter.playCommand.addTarget { event in
            self.play()
            return .success
        }
        
        remoteCommandCenter.pauseCommand.addTarget { event in
            self.pause()
            return .success
        }
        
        remoteCommandCenter.nextTrackCommand.addTarget { event in
            self.next()
            return .success
        }
        
        remoteCommandCenter.previousTrackCommand.addTarget { event in
            self.previous()
            return .success
        }
        
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
            let player = self.player,
            let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            let targetTime = CMTime(seconds: event.positionTime, preferredTimescale: 1)
            player.seek(to: targetTime)
            return .success
        }
    }
    
    func playSong(_ song: Song) throws {
        cleanup()
        let playerItem = AVPlayerItem(url: song.streamUrl!)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        let interval = CMTimeMakeWithSeconds(1.0, preferredTimescale: 1)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateTime()
        }
        playerItemStatusObserver = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            if item.status == .readyToPlay {
                self?.updateNowPlayingInfo(song: song)
                self?.currentSong = song
                self?.isPlaying = true
            }
        }
    }
    
    func getQueue() -> [Song] {
        queue
    }
    
    func getCurrentIndex() -> Int {
        currentIndex
    }
    
    func playAndBuildQueue(_ song: Song, songsToPlay: [Song]) throws {
        flushQueue()
        
        for s in songsToPlay {
            queue.append(s)
            if (s == song) {
                currentIndex = songsToPlay.firstIndex(of: song)!
            }
        }
        
        try playSong(queue[currentIndex])
    }
    
    func flushQueue() {
        queue.removeAll()
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
        isPlaying ? pause() : play()
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func next() {
        currentIndex += 1;
        if currentIndex >= queue.count {
            currentIndex = 0;
        }
        try? playSong(queue[currentIndex])
    }
    
    func previous() {
        currentIndex -= 1;
        if currentIndex < 0 {
            currentIndex = queue.count - 1;
        }
        try? playSong(queue[currentIndex])
    }
    
    func seek(to time: Double) {
        self.player?.seek(to: CMTimeMakeWithSeconds(time, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
    }
    
    func cleanup() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
        if let playbackObserverToken = playbackObserverToken {
            player?.removeTimeObserver(playbackObserverToken)
        }
        playerItemStatusObserver?.invalidate()
    }
}

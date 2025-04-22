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

enum RepeatMode: String, CaseIterable {
    case none = "None"
    case repeatAll = "Repeat All"
    case repeatOne = "Repeat One"
}

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
    private var isShuffleEnabled: Bool = true
    private var repeatMode: RepeatMode = .none
    
    private let playSongDebouncer = DebounceService(delay: 0.2)
    
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
    
    private func setupBackgroundSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setupAutomaticPlayback() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] _ in
                self?.onSongEnded()
            }
            .store(in: &cancellables)
    }
    
    private func updateNowPlayingInfo(song: Song) {
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
    
    private func setupRemoteControls() {
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
    
    private func playSong(_ song: Song) {
        isShuffleEnabled = false
        
        playSongDebouncer.run {
            self.cleanup()
            
            let playerItem = AVPlayerItem(url: song.streamUrl!)
            self.player = AVPlayer(playerItem: playerItem)
            self.player?.play()
            
            let interval = CMTimeMakeWithSeconds(1.0, preferredTimescale: 1)
            self.timeObserverToken = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                self?.updateTime()
            }
            
            self.playerItemStatusObserver = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
                if item.status == .readyToPlay {
                    self?.updateNowPlayingInfo(song: song)
                    self?.currentSong = song
                    self?.isPlaying = true
                    self?.isShuffleEnabled = true
                }
            }
        }
    }
    
    func getQueue() -> [Song] {
        queue
    }
    
    func getCurrentIndex() -> Int {
        currentIndex
    }
    
    func playAndBuildQueue(_ song: Song, songsToPlay: [Song]) {
        guard !songsToPlay.isEmpty else { return }
        
        flushQueue()
        
        for s in songsToPlay {
            queue.append(s)
            if (s == song) {
                currentIndex = songsToPlay.firstIndex(of: song)!
            }
        }
        
        playSong(queue[currentIndex])
    }
    
    func playAtIndex(_ index: Int) {
        currentIndex = index
        playSong(queue[currentIndex])
    }
    
    private func flushQueue() {
        queue.removeAll()
    }
    
    func removeFromQueue(at index: Int) {
        if index == currentIndex {
            return
        }
        
        queue.remove(at: index)
        if index <= currentIndex {
            currentIndex = max(0, currentIndex - 1)
        }
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }

        queue.move(fromOffsets: source, toOffset: destination)

        if sourceIndex == currentIndex {
            if destination > sourceIndex {
                currentIndex = destination - 1
            } else {
                currentIndex = destination
            }
        } else if sourceIndex < currentIndex && destination > currentIndex {
            currentIndex -= 1
        } else if sourceIndex > currentIndex && destination <= currentIndex {
            currentIndex += 1
        }
    }

    func shuffleQueue() {
        guard isShuffleEnabled else { return }
        
        queue.shuffle()
        if let currentId = currentSong?.Id, let index = queue.firstIndex(where: { $0.Id == currentId }) {
            queue.swapAt(currentIndex, index)
        }
    }

    private func updateTime() {
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
        playSong(queue[currentIndex])
    }
    
    func previous() {
        currentIndex -= 1;
        if currentIndex < 0 {
            currentIndex = queue.count - 1;
        }
        playSong(queue[currentIndex])
    }
    
    private func onSongEnded() {
        switch repeatMode {
        case .none:
            if (currentIndex != queue.count - 1) {
                next()
            }
        case .repeatAll:
            next()
        case .repeatOne:
            playAtIndex(currentIndex)
        }
    }
    
    func seek(to time: Double) {
        self.player?.seek(to: CMTimeMakeWithSeconds(time, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
    }
    
    func getRepeatMode() -> RepeatMode {
        repeatMode
    }
    
    func changeQueueMode() {
        let allCases = RepeatMode.allCases
        if let index = allCases.firstIndex(of: repeatMode) {
            let nextIndex = (index + 1) % allCases.count
            repeatMode = allCases[nextIndex]
        }
    }
    
    private func cleanup() {
        if let timeObserverToken = timeObserverToken, let observerPlayer = player {
            observerPlayer.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        if let playbackObserverToken = playbackObserverToken, let observerPlayer = player {
            observerPlayer.removeTimeObserver(playbackObserverToken)
            self.playbackObserverToken = nil
        }

        playerItemStatusObserver?.invalidate()
        playerItemStatusObserver = nil
    }
}

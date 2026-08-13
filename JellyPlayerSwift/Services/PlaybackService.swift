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
import SwiftUI

enum RepeatMode: String, CaseIterable {
    case none = "Never repeat"
    case repeatAll = "Repeat All"
    case repeatOne = "Repeat Once"
    
    var accessibilityLabelKey: LocalizedStringKey {
        switch self {
        case .none:
            return "Never repeat"
        case .repeatAll:
            return "Repeat All"
        case .repeatOne:
            return "Repeat One"
        }
    }
}

@Observable
class PlaybackService {
    static let shared = PlaybackService()
    
    private var player: AVPlayer?
    private var currentTimeTimer: Timer?
    private var playbackObserverToken: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var queue: [Song] = []
    private var defaultQueue: [Song] = []
    private var currentIndex: Int = 0
    private var queueShuffled: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private var isShuffleEnabled: Bool = true
    private var repeatMode: RepeatMode = RepeatMode(rawValue: UserDefaults.standard.string(forKey: repeatKey) ?? "Never repeat") ?? .none
    private var nowPlayingUpdateTimer: Timer?
    private var timeControlObserver: NSKeyValueObservation?
    
    private let playSongDebouncer = DebounceService(delay: 0.2)
    private let artworkService = ArtworkService()
    
    private var preloadedItem: (songId: String, item: AVPlayerItem)?
    
    var currentSong: Song? {
        didSet {
            if currentSong == nil {
                presentation = .hidden
            } else if presentation == .hidden {
                presentation = .mini
            }
        }
    }
    
    var isPlaying: Bool = false
    var isBuffering: Bool = false
    var currentTime: Double = 0
    
    var presentation: PlaybackPresentation = .hidden
    
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
            try audioSession.setCategory(.playback, mode: .default)
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
        let duration = player?.currentItem?.duration.seconds ?? 0
        let currentTime = player?.currentTime().seconds ?? 0
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: song.Name,
            MPMediaItemPropertyArtist: song.Artists.joined(separator: ", "),
            MPMediaItemPropertyAlbumTitle: song.albumName,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: player?.rate ?? 1.0,
            MPNowPlayingInfoPropertyPlaybackQueueIndex: currentIndex,
            MPNowPlayingInfoPropertyPlaybackQueueCount: queue.count
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

        if let img = song.coverImage {
            let artwork = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        } else if let coverUrl = song.coverUrl {
            artworkService.fetchArtwork(url: coverUrl) { image in
                if let img = image {
                    let artwork = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                }
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

        nowPlayingUpdateTimer?.invalidate()

        nowPlayingUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if let player = self.player {
                var updatedInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                updatedInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
                updatedInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
                MPNowPlayingInfoCenter.default().nowPlayingInfo = updatedInfo
            }
        }

        RunLoop.main.add(nowPlayingUpdateTimer!, forMode: .common)
    }

    private func setupRemoteControls() {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        
        remoteCommandCenter.playCommand.addTarget { _ in
            Task { @MainActor in
                self.play()
            }
            return .success
        }
        
        remoteCommandCenter.pauseCommand.addTarget { _ in
            Task { @MainActor in
                self.pause()
            }
            return .success
        }
        
        remoteCommandCenter.togglePlayPauseCommand.addTarget { _ in
            self.togglePlayPause()
            return .success
        }
        
        remoteCommandCenter.nextTrackCommand.addTarget { _ in
            self.next()
            return .success
        }
        
        remoteCommandCenter.previousTrackCommand.addTarget { _ in
            self.previous()
            return .success
        }
        
        remoteCommandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
            let player = self.player,
            let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            let targetTime = CMTime(seconds: event.positionTime, preferredTimescale: 1)
            player.seek(to: targetTime)
            return .success
        }
        
        remoteCommandCenter.changeShuffleModeCommand.isEnabled = true
        remoteCommandCenter.changeShuffleModeCommand.addTarget { [weak self] event in
            guard let self = self, let event = event as? MPChangeShuffleModeCommandEvent else {
                return .commandFailed
            }
            handleRemoteShuffleCHange(mode: event.shuffleType)
            return .success
        }
        
        remoteCommandCenter.changeRepeatModeCommand.isEnabled = true
        remoteCommandCenter.changeRepeatModeCommand.addTarget { [weak self] event in
            guard let self = self, let event = event as? MPChangeRepeatModeCommandEvent else {
                return .commandFailed
            }
            handleRemoteRepeatChange(mode: event.repeatType)
            return .success
        }
    }
    
    private func startCurrentTimeTimer() {
        currentTimeTimer?.invalidate()
        currentTimeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self, let player = self.player else { return }
            let seconds = player.currentTime().seconds
            if !seconds.isNaN && seconds.isFinite {
                self.currentTime = seconds
            }
        }
        RunLoop.main.add(currentTimeTimer!, forMode: .common)
    }
    
    private func playSong(_ song: Song) {
        isShuffleEnabled = false
        
        AudioAnalysisService.shared.finalizeAndSave()
        
        if let current = currentSong {
            NotificationCenter.default.post(
                name: .songPlaybackFinished,
                object: current
            )
        }
        
        playSongDebouncer.run {
            self.cleanup()
            var playerItem: AVPlayerItem
            var playbackLocation: String = ""
            
            if let preloaded = self.preloadedItem, preloaded.songId == song.Id {
                playerItem = preloaded.item
                self.preloadedItem = nil
                playbackLocation = "Preloaded item"
            } else if let localPath = song.localFilePath {
                playerItem = AVPlayerItem(url: localPath)
                playbackLocation = "Local File: \(localPath.absoluteString)"
            } else {
                playerItem = AVPlayerItem(url: song.streamUrl!)
                playerItem.preferredForwardBufferDuration = 15
                playbackLocation = "Remote Stream: \(song.streamUrl?.absoluteString ?? "")"
            }
            
            print("Playing '\(song.Name)' from: \(playbackLocation)")
            
            if let existingPlayer = self.player {
                existingPlayer.replaceCurrentItem(with: playerItem)
            } else {
                self.player = AVPlayer(playerItem: playerItem)
            }
            
            AudioAnalysisService.shared.attachTap(to: playerItem, for: song)
            
            self.player?.play()
            self.startCurrentTimeTimer()
            self.currentSong = song
            self.isPlaying = true
            self.updateNowPlayingInfo(song: song)
            
            self.timeControlObserver = self.player?.observe(
                \.timeControlStatus, options: [.new]
            ) { [weak self] player, _ in
                DispatchQueue.main.async {
                    self?.isBuffering = player.timeControlStatus == .waitingToPlayAtSpecifiedRate
                }
            }
            
            self.playerItemStatusObserver = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
                if item.status == .readyToPlay {
                    self?.updateNowPlayingInfo(song: song)
                    self?.isShuffleEnabled = true
                    self?.preloadNext()
                }
            }
        }
    }
    
    private func preloadNext() {
        guard !queue.isEmpty else { return }
        let nextIndex = (currentIndex + 1) % queue.count
        guard queue.indices.contains(nextIndex) else { return }
        let nextSong = queue[nextIndex]
        
        if preloadedItem?.songId == nextSong.Id { return }
        
        let item: AVPlayerItem
        if let localPath = nextSong.localFilePath {
            item = AVPlayerItem(url: localPath)
        } else if let streamUrl = nextSong.streamUrl {
            item = AVPlayerItem(url: streamUrl)
            item.preferredForwardBufferDuration = 15
        } else {
            return
        }
        
        preloadedItem = (nextSong.Id, item)
    }
    
    private func invalidatePreload() {
        preloadedItem = nil
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
        defaultQueue = []
        invalidatePreload()
        
        for s in songsToPlay {
            queue.append(s)
            defaultQueue.append(s)
            if (s == song) {
                currentIndex = songsToPlay.firstIndex(of: song)!
            }
        }
        
        playSong(queue[currentIndex])
    }
    
    func playAtIndex(_ index: Int) {
        currentIndex = index
        invalidatePreload()
        playSong(queue[currentIndex])
    }
    
    private func flushQueue() {
        queue.removeAll()
    }
    
    func removeFromQueue(at index: Int) {
        if index == currentIndex {
            return
        }
        
        let songToRemove = queue[index]
        queue.remove(at: index)
        defaultQueue = defaultQueue.filter { $0 != songToRemove }
        if index <= currentIndex {
            currentIndex = max(0, currentIndex - 1)
        }
        invalidatePreload()
    }
    
    func addToQueue(songs: [Song]) {
        queue += songs
        defaultQueue += songs
        if preloadedItem == nil {
            preloadNext()
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
        invalidatePreload()
    }

    func shuffleQueue() {
        guard isShuffleEnabled else { return }
        queueShuffled.toggle()
        invalidatePreload()
        if queueShuffled {
            defaultQueue = queue
            do {
                queue = try RecommendationService.shared.smartShuffle(songs: queue, currentSong: currentSong)
            } catch {
                queue.shuffle()
            }
            for index in queue.indices {
                if queue[index].Id == currentSong?.Id {
                    queue.swapAt(0, index)
                    currentIndex = 0
                    updateRemoteCommandCenterState()
                    preloadNext()
                    return
                }
            }
        } else {
            if !defaultQueue.isEmpty {
                queue = defaultQueue
                for index in queue.indices {
                    if queue[index].Id == currentSong?.Id {
                        currentIndex = index
                        updateRemoteCommandCenterState()
                        preloadNext()
                        return
                    }
                }
            }
        }
        updateRemoteCommandCenterState()
    }
    
    private func handleRemoteShuffleCHange(mode: MPShuffleType) {
        switch mode {
        case .off:
            if queueShuffled { shuffleQueue() }
        case .items, .collections:
            if !queueShuffled { shuffleQueue() }
        default:
            break
        }
        updateRemoteCommandCenterState()
    }
    
    private func handleRemoteRepeatChange(mode: MPRepeatType) {
        switch mode {
        case .off:
            repeatMode = .none
        case .one:
            repeatMode = .repeatOne
        case .all:
            repeatMode = .repeatAll
        default:
            break
        }
        UserDefaults.standard.set(repeatMode.rawValue, forKey: repeatKey)
        updateRemoteCommandCenterState()
    }
    
    private func updateRemoteCommandCenterState() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.changeShuffleModeCommand.currentShuffleType = queueShuffled ? .items : .off
        
        switch repeatMode {
        case .none:
            commandCenter.changeRepeatModeCommand.currentRepeatType = .off
        case .repeatAll:
            commandCenter.changeRepeatModeCommand.currentRepeatType = .all
        case .repeatOne:
            commandCenter.changeRepeatModeCommand.currentRepeatType = .one
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
        if currentTime > 5 {
            seek(to: 0)
        } else {
            currentIndex -= 1;
            if currentIndex < 0 {
                currentIndex = queue.count - 1;
            }
            playSong(queue[currentIndex])
        }
    }
    
    private func onSongEnded() {
        pause()
        switch repeatMode {
        case .none:
            if (currentIndex != queue.count - 1) {
                next()
            }
        case .repeatAll:
            next()
        case .repeatOne:
            invalidatePreload()
            playAtIndex(currentIndex)
        }
    }
    
    func seek(to time: Double) {
        let targetTime = CMTimeMakeWithSeconds(time, preferredTimescale: 600)
        self.player?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .positiveInfinity) { [weak self] success in
            DispatchQueue.main.async {
                guard let self else { return }
                if success {
                    self.currentTime = time
                    if self.isPlaying {
                        self.player?.play()
                    }
                }
            }
        }
    }
    
    func getRepeatMode() -> RepeatMode {
        repeatMode
    }
    
    func getQueueShuffled() -> Bool {
        queueShuffled
    }
    
    func changeQueueMode() {
        let allCases = RepeatMode.allCases
        if let index = allCases.firstIndex(of: repeatMode) {
            let nextIndex = (index + 1) % allCases.count
            repeatMode = allCases[nextIndex]
            UserDefaults.standard.set(repeatMode.rawValue, forKey: repeatKey)
            updateRemoteCommandCenterState()
        }
    }
    
    private func cleanup() {
        if let playbackObserverToken = playbackObserverToken, let observerPlayer = player {
            observerPlayer.removeTimeObserver(playbackObserverToken)
            self.playbackObserverToken = nil
        }

        playerItemStatusObserver?.invalidate()
        playerItemStatusObserver = nil
        
        nowPlayingUpdateTimer?.invalidate()
        nowPlayingUpdateTimer = nil
        
        timeControlObserver?.invalidate()
        timeControlObserver = nil
        
        currentTimeTimer?.invalidate()
        currentTimeTimer = nil
    }
}

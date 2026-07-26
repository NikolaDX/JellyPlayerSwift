//
//  AlbumTracksView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

extension AlbumTracksView {
    @Observable
    class ViewModel {
        let album: Album
        var songs: [Song] = []
        var isLoading: Bool = false
        
        private var favoritesService: FavoritesService
        private var downloadService: DownloadService
        
        var lastFetched: Date?
        let cacheLifetime: TimeInterval = 300
        
        init(album: Album, favoritesService: FavoritesService, downloadService: DownloadService) {
            self.album = album
            self.favoritesService = favoritesService
            self.downloadService = downloadService
        }
        
        func fetchSongs(forceRefresh: Bool = false) {
            if !forceRefresh,
               let lastFetched,
               Date().timeIntervalSince(lastFetched) < cacheLifetime,
               !songs.isEmpty {
                return
            }
            
            isLoading = true
            let albumService = AlbumService()
            Task { @MainActor in
                songs = await albumService.fetchAlbumSongs(albumId: album.Id)
                self.lastFetched = Date()
                withAnimation {
                    isLoading = false
                }
            }
        }
        
        func songsByDisc() -> [(disc: Int, songs: [Song])] {
            let grouped = Dictionary(grouping: songs) { song in
                song.ParentIndexNumber ?? 1
            }
            
            return grouped
                .map { ($0.key, $0.value.sorted { ($0.IndexNumber ?? 0) < ($1.IndexNumber ?? 0) })}
                .sorted { $0.disc < $1.disc }
        }
        
        var hasMultipleDiscs: Bool {
            songsByDisc().count > 1
        }
        
        func playSong(_ song: Song) {
            PlaybackService.shared.playAndBuildQueue(song, songsToPlay: songs)
        }
        
        func shufflePlay() {
            let shuffledSongs = songs.shuffled()
            PlaybackService.shared.playAndBuildQueue(shuffledSongs[0], songsToPlay: shuffledSongs)
        }
        
        func formatTime(_ time: Double) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
        func addToFavorites(_ song: Song) {
            Task { @MainActor in
                await favoritesService.addSongToFavorites(song: song)
            }
        }
        
        func removeFromFavorites(_ song: Song) {
            Task { @MainActor in
                await favoritesService.removeFromFavorites(song: song)
            }
        }
        
        func downloadSong(_ song: Song) {
            downloadService.downloadSong(song)
        }
        
        func removeDownload(_ song: Song) {
            downloadService.removeDownload(song)
        }
        
        func generateInstantMix(_ song: Song) {
            Task {
                let songsToPlay = await SongsService().generateInstantMix(songId: song.Id)
                PlaybackService.shared.playAndBuildQueue(songsToPlay[0], songsToPlay: songsToPlay)
            }
        }
    }
}

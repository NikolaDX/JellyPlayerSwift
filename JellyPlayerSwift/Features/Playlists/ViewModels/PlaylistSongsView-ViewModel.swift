//
//  PlaylistSongsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUI

extension PlaylistSongsView {
    @Observable
    class ViewModel {
        var songs: [Song] = []
        var isLoading: Bool = false
        
        var suggestedSongs: [Song] = []
        var isLoadingSuggestions: Bool = false
        
        private var favoritesService: FavoritesService
        private var downloadService: DownloadService
        
        var lastFetched: Date?
        let cacheLifetime: TimeInterval = 300
        
        let playlist: Playlist
        
        init(playlist: Playlist, favoritesService: FavoritesService, downloadService: DownloadService) {
            self.playlist = playlist
            self.favoritesService = favoritesService
            self.downloadService = downloadService
        }
        
        var selectedSortOption: String = "PlaylistOrder"
        var selectedSortOrder: String = "Ascending"
        var filterText: String = ""
        
        var filteredSongs: [Song] {
            filterText.isEmpty ? sortedSongs : sortedSongs.filter {
                $0.Name.localizedCaseInsensitiveContains(filterText) ||
                $0.Artists.joined(separator: ", ").localizedCaseInsensitiveContains(filterText) ||
                $0.albumName.localizedCaseInsensitiveContains(filterText)
            }
        }
        
        var sortedSongs: [Song] {
            let sorted: [Song]
            
            switch selectedSortOption {
            case "PlaylistOrder":
                sorted = songs
            case "Name":
                sorted = songs.sorted { $0.Name < $1.Name }
            case "Album":
                sorted = songs.sorted { $0.albumName < $1.albumName }
            case "Artist":
                sorted = songs.sorted { $0.Artists.joined(separator: ", ") < $1.Artists.joined(separator: ", ") }
            case "DateAdded":
                sorted = songs.sorted { $0.DateCreated ?? "" < $1.DateCreated ?? "" }
            case "PlayCount":
                sorted = songs.sorted { $0.UserData.PlayCount < $1.UserData.PlayCount }
            default:
                sorted = songs
            }
            
            if selectedSortOrder == "Descending" {
                return sorted.reversed()
            } else {
                return sorted
            }
        }
        
        func fetchSongs(forceRefresh: Bool = false) {
            if !forceRefresh,
                let lastFetched,
                Date().timeIntervalSince(lastFetched) < cacheLifetime,
                !songs.isEmpty {
                return
            }
            
            isLoading = true
            let playlistsService = PlaylistsService()
            Task { @MainActor in
                songs = await playlistsService.fetchPlaylistSongs(playlistId: playlist.Id)
                self.lastFetched = Date()
                withAnimation {
                    isLoading = false
                }
                
                await fetchSuggestions()
            }
        }
        
        func removeSongsFromPlaylist(songIds: [String], playlistId: String) {
            let playlistsSerivce = PlaylistsService()
            Task { @MainActor in
                do {
                    try await playlistsSerivce.removeSongsFromPlaylist(songIds: songIds, playlistId: playlistId)
                    fetchSongs(forceRefresh: true)
                } catch {
                    print("Error removing song: \(error.localizedDescription)")
                }
            }
        }
        
        func playFrom(song: Song) {
            PlaybackService.shared.playAndBuildQueue(song, songsToPlay: songs)
        }
        
        func playAll() {
            if !songs.isEmpty {
                PlaybackService.shared.playAndBuildQueue(songs[0], songsToPlay: songs)
            }
        }
        
        func shufflePlay() {
            if !songs.isEmpty {
                let shuffledSongs = songs.shuffled()
                PlaybackService.shared.playAndBuildQueue(shuffledSongs[0], songsToPlay: shuffledSongs)
            }
        }
        
        func addToFavorites(song: Song) {
            Task { @MainActor in
                await favoritesService.addSongToFavorites(song: song)
            }
        }
        
        func removeFromFavorites(song: Song) {
            Task { @MainActor in
                await favoritesService.removeFromFavorites(song: song)
            }
        }
        
        func downloadSong(song: Song) {
            downloadService.downloadSong(song)
        }
        
        func removeDownload(song: Song) {
            downloadService.removeDownload(song)
        }
        
        func generateInstantMix(songId: String) {
            let songsService = SongsService()
            Task {
                let songsToPlay = await songsService.generateInstantMix(songId: songId)
                if !songsToPlay.isEmpty {
                    PlaybackService.shared.playAndBuildQueue(songsToPlay[0], songsToPlay: songsToPlay)
                }
            }
        }
        
        func fetchSuggestions() async {
            isLoadingSuggestions = true
            
            let songsService = SongsService()
            
            let candidatePool = await songsService.fetchAllSongs()
            
            let existingSongIds = Set(songs.map { $0.Id })
            
            let unplayedCandidates = candidatePool.filter { !existingSongIds.contains($0.Id) }
            
            let scored = RecommendationService.shared.score(
                toScore: unplayedCandidates,
                request: .playlist(playlistSongs: self.songs)
            )
            
            let topSuggestions = scored
                .sorted { $0.score > $1.score }
                .prefix(3)
                .map { $0.song }
            
            withAnimation {
                self.suggestedSongs = Array(topSuggestions)
                isLoadingSuggestions = false
            }
        }
        
        func addSuggestedSong(_ song: Song) {
            let playlistsService = PlaylistsService()
            
            Task { @MainActor in
                do {
                    try await playlistsService.addSongsToPlaylist(songIds: [song.Id], playlistId: playlist.Id)
                    
                    withAnimation {
                        if let index = suggestedSongs.firstIndex(where: { $0.Id == song.Id }) {
                            suggestedSongs.remove(at: index)
                        }
                    }
                    
                    fetchSongs(forceRefresh: true)
                } catch {
                    print("Error adding suggested song: \(error.localizedDescription)")
                }
            }
        }
    }
}

//
//  PlaylistSongsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUICore

extension PlaylistSongsView {
    @Observable
    class ViewModel {
        var songs: [Song] = []
        var isLoading: Bool = false
        
        private var favoritesService: FavoritesService
        private var downloadService: DownloadService
        
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
                $0.Album.localizedCaseInsensitiveContains(filterText)
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
                sorted = songs.sorted { $0.Album < $1.Album }
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
        
        func fetchSongs() {
            isLoading = true
            let playlistsService = PlaylistsService()
            Task { @MainActor in
                songs = await playlistsService.fetchPlaylistSongs(playlistId: playlist.Id)
                withAnimation {
                    isLoading = false
                }
            }
        }
        
        func removeSongsFromPlaylist(songIds: [String], playlistId: String) {
            let playlistsSerivce = PlaylistsService()
            Task { @MainActor in
                do {
                    try await playlistsSerivce.removeSongsFromPlaylist(songIds: songIds, playlistId: playlistId)
                    fetchSongs()
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
    }
}

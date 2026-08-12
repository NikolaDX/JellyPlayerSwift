//
//  SearchView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 11. 8. 2026..
//

import Foundation

extension SearchView {
    @Observable
    class ViewModel {
        let libraryService = LibraryService.shared
        let downloadService = DownloadService.shared
        
        var searchQuery: String = "" {
            didSet {
               scheduleSearch()
            }
        }
        
        private var debouncedQuery: String = ""
        private var searchTask: Task<Void, Never>?
        
        private func scheduleSearch() {
            searchTask?.cancel()
            let query = searchQuery
            
            guard !query.isEmpty else {
                debouncedQuery = ""
                return
            }
            
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 250_000_000)
                guard !Task.isCancelled else { return }
                debouncedQuery = query
            }
        }
        
        var playlists: [Playlist] {
            guard !debouncedQuery.isEmpty else { return [] }
            return libraryService.playlists.filter { $0.Name.localizedCaseInsensitiveContains(debouncedQuery) }
        }
        
        var artists: [Artist] {
            guard !debouncedQuery.isEmpty else { return [] }
            return libraryService.artists.filter { $0.Name.localizedCaseInsensitiveContains(debouncedQuery) }
        }
        
        var albums: [Album] {
            guard !debouncedQuery.isEmpty else { return [] }
            return libraryService.albums.filter { $0.Name.localizedCaseInsensitiveContains(debouncedQuery) }
        }
        
        var songs: [Song] {
            guard !debouncedQuery.isEmpty else { return [] }
            return libraryService.songs.filter { $0.Name.localizedCaseInsensitiveContains(debouncedQuery) }
        }
        
        var genres: [Genre] {
            guard !debouncedQuery.isEmpty else { return [] }
            return libraryService.genres.filter { $0.Name.localizedCaseInsensitiveContains(debouncedQuery) }
        }
        
        var downloads: [Song] {
            guard !debouncedQuery.isEmpty else { return [] }
            return downloadService.downloads.filter { $0.Name.localizedCaseInsensitiveContains(debouncedQuery) }
        }
    }
}

//
//  LibraryService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 5. 8. 2026..
//

import Foundation

struct LibraryRefreshOptions: OptionSet {
    let rawValue: Int
    
    static let songs = Self(rawValue: 1 << 0)
    static let albums = Self(rawValue: 1 << 1)
    static let playlists = Self(rawValue: 1 << 2)
    static let artists = Self(rawValue: 1 << 3)
    static let genres = Self(rawValue: 1 << 4)
    
    static let all: Self = [
        .songs,
        .albums,
        .playlists,
        .artists,
        .genres
    ]
}

@Observable
final class LibraryService {
    static let shared = LibraryService()
    
    private init() {}
    
    private(set) var songs: [Song] = []
    private(set) var albums: [Album] = []
    private(set) var playlists: [Playlist] = []
    private(set) var artists: [Artist] = []
    private(set) var genres: [Genre] = []
    
    private(set) var isLoading: Bool = false
    private(set) var hasLoadedOnce: Bool = false
    private(set) var lastError: Error?
    
    private var lastFetched: Date?
    private let cacheLifetime: TimeInterval = 300
    
    private let songsService = SongsService()
    private let albumService = AlbumService()
    private let playlistsService = PlaylistsService()
    private let artistsService = ArtistsService()
    private let genresService = GenresService()
    
    private func cacheUrl(for name: String) -> URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("\(name).json")
    }
    
    private func saveCache<T: Encodable>(_ value: T, name: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: cacheUrl(for: name), options: .atomic)
    }
    
    private func loadCache<T: Decodable>(_ type: T.Type, name: String) -> T? {
        guard let data = try? Data(contentsOf: cacheUrl(for: name)) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func loadAll(options: LibraryRefreshOptions = .all, forceRefresh: Bool = false) async {
        if !hasLoadedOnce {
            songs = loadCache([Song].self, name: "songs") ?? songs
            albums = loadCache([Album].self, name: "albums") ?? albums
            playlists = loadCache([Playlist].self, name: "playlists") ?? playlists
            artists = loadCache([Artist].self, name: "artists") ?? artists
            genres = loadCache([Genre].self, name: "genres") ?? genres
        }
        
        if !forceRefresh,
           hasLoadedOnce,
           let lastFetched,
           Date().timeIntervalSince(lastFetched) < cacheLifetime {
            return
        }
        
        isLoading = true
        lastError = nil
        
        async let songsResult = options.contains(.songs)
        ? songsService.fetchAllSongs()
        : songs
        
        
        async let albumsResult = options.contains(.albums)
        ? albumService.fetchAlbums()
        : albums
        
        async let playlistsResult = options.contains(.playlists)
        ? playlistsService.fetchPlaylists()
        : playlists
        
        async let artistsResult = options.contains(.artists)
        ? artistsService.fetchArtists()
        : artists
        
        async let genresResult = options.contains(.genres)
        ? genresService.fetchGenres()
        : genres
        
        songs = await songsResult
        albums = await albumsResult
        playlists = await playlistsResult
        artists = await artistsResult
        genres = await genresResult
        
        saveCache(songs, name: "songs")
        saveCache(albums, name: "albums")
        saveCache(playlists, name: "playlists")
        saveCache(artists, name: "artists")
        saveCache(genres, name: "genres")
        
        lastFetched = Date()
        hasLoadedOnce = true
        isLoading = false
    }
    
    // MARK: - ALBUM
    
    func album(id: String) -> Album? {
        albums.first { $0.Id == id }
    }
    
    func fetchAlbumTracks(for albumId: String) -> [Song] {
        songs.filter {
            if let songAlbumId = $0.AlbumId {
                return songAlbumId == albumId
            } else {
                return false
            }
        }
    }
    
    // MARK: - ARTISTS
    
    func fetchArtistAlbums(for artistId: String) -> [Album] {
        albums.filter { album in
            album.AlbumArtists.contains { $0.Id == artistId }
        }
    }
    
    // MARK: - GENRES
   
    func fetchGenreAlbums(genre: String) -> [Album] {
        albums.filter { album in
            if let albumGenres = album.Genres {
                return albumGenres.contains(genre)
            } else {
                return false
            }
        }
    }
    
    // MARK: - PLAYLISTS
    
    func renamePlaylist(id: String, newName: String) {
        guard let index = playlists.firstIndex(where: { $0.Id == id }) else { return }
        playlists[index].Name = newName
    }
    
    func removePlaylist(playlistId: String) {
        playlists.removeAll(where: { $0.Id == playlistId })
    }
    
    func adjustPlaylistSongCount(id: String, by delta: Int) {
        guard let index = playlists.firstIndex(where: { $0.Id == id }) else { return }
        playlists[index].NumberOfSongs = (playlists[index].NumberOfSongs ?? 0) + delta
    }
    
    // MARK: - SONGS
    
    func isFavorite(songId: String) -> Bool {
        songs.first(where: { $0.Id == songId })?.UserData.IsFavorite ?? false
    }
    
    func fetchFavorites() -> [Song] {
        songs.filter { $0.UserData.IsFavorite }
    }
    
    func setFavorite(for songId: String, isFavorite: Bool) {
        guard let index = songs.firstIndex(where: { $0.Id == songId }) else { return }
        songs[index].UserData.IsFavorite = isFavorite
    }
}

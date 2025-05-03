//
//  PlaylistsService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import Foundation

class PlaylistsService {
    private var serverUrl: String? {
        get { return UserDefaults.standard.string(forKey: serverKey) }
    }
    
    private var userId: String? {
        get { return UserDefaults.standard.string(forKey: userKey) }
    }
    
    private var accessToken: String? {
        get { return UserDefaults.standard.string(forKey: accessKey) }
    }
    
    let jellyfinService = JellyfinService()
    
    func fetchPlaylists() async -> [Playlist] {
        if let data = await jellyfinService.fetchItems(queryItems: [
            URLQueryItem(name: "IncludeItemTypes", value: "Playlist"),
            URLQueryItem(name: "Fields", value: "DateCreated"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "SortBy", value: "Name"),
            URLQueryItem(name: "SortOrder", value: "Ascending")
        ]) {
            if let decodedResponse = try? JSONDecoder().decode(PlaylistResponse.self, from: data) {
                let playlists = decodedResponse.Items

                for i in playlists.indices {
                    let playlistId = playlists[i].Id
                    let songCount = await fetchPlaylistCount(for: playlistId)
                    playlists[i].NumberOfSongs = songCount
                }

                return playlists
            }
        }
        
        return []
    }
    
    func fetchPlaylistCount(for playlistId: String) async -> Int {
        return await fetchPlaylistSongs(playlistId: playlistId).count
    }
    
    func fetchPlaylistSongs(playlistId: String) async -> [Song] {
        if let data = await jellyfinService.fetchSpecific(queryItems: [
            URLQueryItem(name: "IncludeItemTypes", value: "Audio"),
            URLQueryItem(name: "Fields", value: "DateCreated")
        ], toFetch: "Playlists/\(playlistId)/Items") {
            do {
                let raw = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let itemsArray = raw?["Items"] as? [[String: Any]] {
                    return itemsArray.compactMap { itemDict in
                        guard let itemData = try? JSONSerialization.data(withJSONObject: itemDict) else { return nil }
                        return try? JSONDecoder().decode(Song.self, from: itemData)
                    }
                }
            } catch {
                print("Failed to parse playlist response: \(error)")
            }
        }
        
        return []
    }
    
    func createPlaylist(playlistName: String) async throws {
        if playlistName.isEmpty {
            throw "Playlist name can't be empty!"
        }
        
        try await jellyfinService.addToServerWithHttpBody(
            queryItems: [],
            path: "Playlists",
            httpBody: [
                "Name": playlistName
            ])
    }
    
    func deletePlaylist(playlistId: String) async throws {
        try await jellyfinService.removeItemFromServer(
            queryItems: [],
            path: playlistId
        )
    }
    
    func addSongsToPlaylist(songIds: [String], playlistId: String) async throws {
        try await jellyfinService.addToServerWithHttpBody(
            queryItems: [
                URLQueryItem(name: "ids", value: songIds.joined(separator: ","))
            ],
            path: "Playlists/\(playlistId)/Items",
            httpBody: [:]
        )
    }
    
    func removeSongsFromPlaylist(songIds: [String], playlistId: String) async throws {
        try await jellyfinService.removeFromServerWithHttpBody(
            queryItems: [
                URLQueryItem(name: "entryIds", value: songIds.joined(separator: ","))
            ],
            path: "Playlists/\(playlistId)/Items",
            httpBody: [:]
        )
    }
    
    func generateInstantMix(playlistId: String) async -> [Song] {
        if let data = await jellyfinService.fetchSpecific(queryItems: [], toFetch: "Playlists/\(playlistId)/InstantMix") {
            do {
                let raw = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let itemsArray = raw?["Items"] as? [[String: Any]] {
                    return itemsArray.compactMap { itemDict in
                        guard let itemData = try? JSONSerialization.data(withJSONObject: itemDict) else { return nil }
                        return try? JSONDecoder().decode(Song.self, from: itemData)
                    }
                }
            } catch {
                print("Failed to parse response: \(error)")
            }
        }
        
        return []
    }
    
    func downloadPlaylistSongs(playlistId: String) async {
        let playlistSongs = await fetchPlaylistSongs(playlistId: playlistId)
        for song in playlistSongs {
            DownloadService.shared.downloadSong(song)
        }
    }
    
    func renamePlaylist(playlistId: String, newName: String) async throws {
        if newName.isEmpty {
            throw "Playlist name can't be empty!"
        }
        
        try await jellyfinService.addToServerWithHttpBody(
            queryItems: [],
            path: "Playlists/\(playlistId)",
            httpBody: [
                "Name": newName
        ])
    }
}

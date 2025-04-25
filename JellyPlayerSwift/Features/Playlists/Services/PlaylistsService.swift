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
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "SortBy", value: "Name"),
            URLQueryItem(name: "SortOrder", value: "Ascending")
        ]) {
            if let decodedResponse = try? JSONDecoder().decode(PlaylistResponse.self, from: data) {
                return decodedResponse.Items
            }
        }
        
        return []
    }
    
    func fetchPlaylistSongs(playlistId: String) async -> [Song] {
        if let data = await jellyfinService.fetchSpecific(queryItems: [
            URLQueryItem(name: "IncludeItemTypes", value: "Audio")
        ], toFetch: "Playlists/\(playlistId)/Items") {
            if let decodedResponse = try? JSONDecoder().decode(SongResponse.self, from: data) {
                return decodedResponse.Items
            }
        }
        
        return []
    }
    
    func createPlaylist(playlistName: String) async throws {
        try await jellyfinService.addToServerWithHttpBody(
            queryItems: [],
            path: "Playlists",
            httpBody: [
                "Name": playlistName
            ])
    }
    
}

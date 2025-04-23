//
//  AlbumService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Foundation

class AlbumService {
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
    
    func fetchAlbums() async -> [Album] {
        if let data = await jellyfinService.fetchItems(queryItems: [
            URLQueryItem(name: "IncludeItemTypes", value: "MusicAlbum"),
            URLQueryItem(name: "Fields", value: "Genres,AlbumArtistIds,AlbumArtists"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "SortBy", value: "Name"),
            URLQueryItem(name: "SortOrder", value: "Ascending")
        ]) {
            if let decodedResponse = try? JSONDecoder().decode(AlbumResponse.self, from: data) {
                return decodedResponse.Items
            }
        }
        
        return []
    }
    
    func fetchAlbumSongs(albumId: String) async -> [Song] {
        if let data = await jellyfinService.fetchItems(queryItems: [
            URLQueryItem(name: "ParentId", value: albumId),
            URLQueryItem(name: "IncludeItemTypes", value: "Audio"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "SortBy", value: "IndexNumber"),
            URLQueryItem(name: "SortOrder", value: "Ascending")
        ]) {
            if let decodedResponse = try? JSONDecoder().decode(SongResponse.self, from: data) {
                return decodedResponse.Items
            }
        }
        
        return []
    }
}

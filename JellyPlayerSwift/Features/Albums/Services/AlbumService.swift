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
    
    func fetchRandomAlbums() async -> [Album] {
        if let data = await jellyfinService.fetchItems(queryItems: [
            URLQueryItem(name: "IncludeItemTypes", value: "MusicAlbum"),
            URLQueryItem(name: "Fields", value: "Genres,AlbumArtistIds,AlbumArtists"),
            URLQueryItem(name: "Recursive", value: "true")
        ]) {
            if let decodedResponse = try? JSONDecoder().decode(AlbumResponse.self, from: data) {
                return decodedResponse.Items.shuffled()
            }
        }
        
        return []
    }
    
    func fetchAlbumSongs(albumId: String) async -> [Song] {
        if let data = await jellyfinService.fetchItems(queryItems: [
            URLQueryItem(name: "ParentId", value: albumId),
            URLQueryItem(name: "IncludeItemTypes", value: "Audio"),
            URLQueryItem(name: "Fields", value: "DateCreated"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "SortBy", value: "IndexNumber"),
            URLQueryItem(name: "SortOrder", value: "Ascending")
        ]) {
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
}

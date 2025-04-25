//
//  FavoritesService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import Foundation

class FavoritesService {
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
    
    func fetchFavoriteSongs() async -> [Song] {
        if let data = await jellyfinService.fetchItems(queryItems: [
            URLQueryItem(name: "IncludeItemTypes", value: "Audio"),
            URLQueryItem(name: "IsFavorite", value: "true"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "SortBy", value: "Name"),
            URLQueryItem(name: "SortOrder", value: "Ascending")
        ]) {
            if let decodedResponse = try? JSONDecoder().decode(SongResponse.self, from: data) {
                return decodedResponse.Items
            }
        }
        
        return []
    }
    
    func addSongToFavorites(song: Song) {
        let jellyfinService = JellyfinService()
        jellyfinService.addToServer(queryItems: [], path: "FavoriteItems/\(song.Id)")
        song.UserData.IsFavorite = true
    }
    
    func removeFromFavorites(song: Song) {
        let jellyfinService = JellyfinService()
        jellyfinService.removeFromServer(queryItems: [], path: "FavoriteItems/\(song.Id)")
        song.UserData.IsFavorite = false
    }
}

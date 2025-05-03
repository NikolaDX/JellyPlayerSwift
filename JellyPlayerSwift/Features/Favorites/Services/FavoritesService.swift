//
//  FavoritesService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import Foundation

class FavoritesService: ObservableObject {
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
            URLQueryItem(name: "Fields", value: "DateCreated"),
            URLQueryItem(name: "IsFavorite", value: "true"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "SortBy", value: "Name"),
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
    
    func addSongToFavorites(song: Song) async {
        do {
            try await jellyfinService.addToServer(queryItems: [], path: "FavoriteItems/\(song.Id)")
            song.UserData.IsFavorite = true
            Task { @MainActor in
                objectWillChange.send()
            }
        } catch {
            print("Error adding to favorites: \(error.localizedDescription)")
        }
    }
    
    func removeFromFavorites(song: Song) async {
        do {
            try await jellyfinService.removeFromServer(queryItems: [], path: "FavoriteItems/\(song.Id)")
            song.UserData.IsFavorite = false
            Task { @MainActor in
                objectWillChange.send()
            }
        } catch {
            print("Error removing from favorites: \(error.localizedDescription)")
        }
    }
}

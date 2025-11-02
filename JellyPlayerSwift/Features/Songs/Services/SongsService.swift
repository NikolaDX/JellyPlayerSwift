//
//  SongsService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import Foundation

class SongsService {
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
    
    func fetchAllSongs() async -> [Song] {
        if let data = await jellyfinService.fetchItems(queryItems: [
            URLQueryItem(name: "IncludeItemTypes", value: "Audio"),
            URLQueryItem(name: "Fields", value: "DateCreated"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "SortBy", value: "Name"),
            URLQueryItem(name: "SortOrder", value: "Ascending")
        ]) {
            print(String(data: data, encoding: .utf8) ?? "No data.")
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
    
    func generateInstantMix(songId: String) async -> [Song] {
        if let data = await jellyfinService.fetchSpecific(queryItems: [], toFetch: "Items/\(songId)/InstantMix") {
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
}

//
//  ArtistsService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import Foundation

class ArtistsService {
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
    
    func fetchArtists() async -> [Artist] {
        if let data = await jellyfinService.fetchSpecific(queryItems: [], toFetch: "Artists") {
            if let decodedResponse = try? JSONDecoder().decode(ArtistResponse.self, from: data) {
                return decodedResponse.Items
            }
        }
        
        return []
    }
    
    func fetchArtistAlbums(artistId: String) async -> [Album] {
        if let data = await jellyfinService.fetchItems(queryItems: [
            URLQueryItem(name: "ArtistIds", value: artistId),
            URLQueryItem(name: "IncludeItemTypes", value: "MusicAlbum"),
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
    
    func generateInstantMix(artistId: String) async -> [Song] {
        if let data = await jellyfinService.fetchSpecific(queryItems: [], toFetch: "Artists/\(artistId)/InstantMix") {
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

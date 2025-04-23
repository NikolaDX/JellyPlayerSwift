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
}

//
//  GenresService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import Foundation

class GenresService {
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
    
    func fetchGenres() async -> [Genre] {
        if let data = await jellyfinService.fetchSpecific(queryItems: [
            URLQueryItem(name: "IncludeItemTypes", value: "Audio")
        ], toFetch: "Genres") {
            if let decodedResponse = try? JSONDecoder().decode(GenreResponse.self, from: data) {
                return decodedResponse.Items
            }
        }
        
        return []
    }
    
    func fetchGenreAlbums(genreId: String) async -> [Album] {
        if let data = await jellyfinService.fetchItems(queryItems: [
            URLQueryItem(name: "GenreIds", value: genreId),
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

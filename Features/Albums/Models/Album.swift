//
//  Album.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Foundation

struct AlbumResponse: Codable {
    let Items: [Album]
}

struct Album: Codable, Hashable {
    let Id: String
    let Name: String
    let AlbumArtist: String
    
    var coverUrl: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey) {
            return URL(string: "\(serverUrl)/Items/\(Id)/Images/Primary")
        } else {
            return nil
        }   
    }
}

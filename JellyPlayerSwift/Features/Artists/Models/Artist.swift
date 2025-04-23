//
//  Artist.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import Foundation

struct ArtistResponse: Codable {
    let Items: [Artist]
}

struct Artist: Codable, Hashable {
    let Id: String
    let Name: String
    
    var coverUrl: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey) {
            return URL(string: "\(serverUrl)/Items/\(Id)/Images/Primary")
        } else {
            return nil
        }
    }
}

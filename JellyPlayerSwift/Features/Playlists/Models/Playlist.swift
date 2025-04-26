//
//  Playlist.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import Foundation

struct PlaylistResponse: Codable {
    let Items: [Playlist]
}

class Playlist: Codable {
    let Id: String
    let Name: String
    var NumberOfSongs: Int?
    
    init(Id: String, Name: String) {
        self.Id = Id
        self.Name = Name
    }
    
    var coverUrl: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey) {
            return URL(string: "\(serverUrl)/Items/\(Id)/Images/Primary")
        } else {
            return nil
        }
    }
}

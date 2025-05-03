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

class Playlist: Codable, Equatable {
    let Id: String
    let Name: String
    let DateCreated: String
    var NumberOfSongs: Int?
    
    init(Id: String, Name: String, DateCreated: String) {
        self.Id = Id
        self.Name = Name
        self.DateCreated = DateCreated
    }
    
    var coverUrl: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey) {
            return URL(string: "\(serverUrl)/Items/\(Id)/Images/Primary")
        } else {
            return nil
        }
    }
    
    static func ==(lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.Id == rhs.Id
    }
}

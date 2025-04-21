//
//  Song.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Foundation

struct SongResponse: Codable {
    let Items: [Song]
}

struct Song: Codable, Equatable {
    let Id: String
    let Name: String
    let IndexNumber: Int
    let Album: String
    let AlbumId: String
    let RunTimeTicks: Int
    let Artists: [String]
    
    var streamUrl: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey), let accessToken = UserDefaults.standard.string(forKey: accessKey) {
            return URL(string: "\(serverUrl)/Audio/\(Id)/stream?Static=true&MaxStreamingBitrate=320000&api_key=\(accessToken)")
        } else {
            return nil
        }
    }
    
    var coverUrl: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey) {
            return URL(string: "\(serverUrl)/Items/\(AlbumId)/Images/Primary")
        } else {
            return nil
        }
    }
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        lhs.Id == rhs.Id
    }
}

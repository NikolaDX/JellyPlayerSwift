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

struct Song: Codable {
    let Id: String
    let Name: String
    let IndexNumber: Int
    let Album: String
    let AlbumId: String
    let RunTimeTicks: Int
    let Artists: [String]
}

//
//  Genre.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import Foundation

struct GenreResponse: Codable {
    let Items: [Genre]
}

struct Genre: Codable {
    let Id: String
    let Name: String
}

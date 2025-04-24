//
//  Song-FromLocalFile.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import AVFoundation
import UIKit

extension Song {
    static func fromLocalFile(_ url: URL) async -> Song? {
        let asset = AVURLAsset(url: url)

        do {
            let metadata = try await asset.load(.commonMetadata)

            let title = try await metadata.first(where: { $0.commonKey?.rawValue == "title" })?.load(.stringValue) ?? url.deletingPathExtension().lastPathComponent
            let artist = try await metadata.first(where: { $0.commonKey?.rawValue == "artist" })?.load(.stringValue) ?? "Unknown"
            let album = try await metadata.first(where: { $0.commonKey?.rawValue == "albumName" })?.load(.stringValue) ?? "Unknown"
            let artworkData = try await metadata.first(where: { $0.commonKey?.rawValue == "artwork" })?.load(.dataValue)

            let durationSeconds = try await asset.load(.duration).seconds
            let runTimeTicks = Int(durationSeconds * 10_000_000)

            return Song(
                Id: UUID().uuidString,
                Name: title,
                IndexNumber: 0,
                Album: album,
                AlbumId: UUID().uuidString,
                RunTimeTicks: runTimeTicks,
                Artists: [artist],
                UserData: JellyPlayerSwift.UserData(IsFavorite: false),
                coverImageData: artworkData,
                localFilePath: url
            )
        } catch {
            print("Error loading metadata for \(url): \(error)")
            return nil
        }
    }
}



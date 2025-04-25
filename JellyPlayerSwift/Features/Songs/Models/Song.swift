//
//  Song.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct SongResponse: Codable {
    let Items: [Song]
}

struct UserData: Codable {
    var IsFavorite: Bool
}

class Song: Codable, Equatable {
    let Id: String
    let Name: String
    let IndexNumber: Int
    let Album: String
    let AlbumId: String
    let RunTimeTicks: Int
    let Artists: [String]
    var UserData: UserData
    var coverImageData: Data?
    
    init(Id: String, Name: String, IndexNumber: Int, Album: String, AlbumId: String, RunTimeTicks: Int, Artists: [String], UserData: UserData) {
        self.Id = Id
        self.Name = Name
        self.IndexNumber = IndexNumber
        self.Album = Album
        self.AlbumId = AlbumId
        self.RunTimeTicks = RunTimeTicks
        self.Artists = Artists
        self.UserData = UserData
    }
    
    var streamUrl: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey), let accessToken = UserDefaults.standard.string(forKey: accessKey) {
            return URL(string: "\(serverUrl)/Audio/\(Id)/stream?Static=true&MaxStreamingBitrate=320000&api_key=\(accessToken)")
        } else {
            return nil
        }
    }
    
    var localFilePath: URL? {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURLS = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            if fileURLS.contains(where: { $0.absoluteString.contains(Id)}) {
                return fileURLS.first { $0.absoluteString.contains(Id) }
            }
        } catch {
            print("Error fetching local file path: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    var coverUrl: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey) {
            return URL(string: "\(serverUrl)/Items/\(AlbumId)/Images/Primary")
        } else {
            return nil
        }
    }
    
    var coverImage: UIImage? {
        guard let data = coverImageData else { return nil }
        return UIImage(data: data)
    }
    
    var downloadURL: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey), let accessToken = UserDefaults.standard.string(forKey: accessKey) {
            return URL(string: "\(serverUrl)/Items/\(Id)/File/?api_key=\(accessToken)")
        } else {
            return nil
        }
    }
    
    var durationInSeconds: Int {
        RunTimeTicks / 10000000
    }
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        lhs.Id == rhs.Id
    }
}

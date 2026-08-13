//
//  Song.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct SongUserData: Codable {
    var IsFavorite: Bool
    var PlayCount: Int
    
    enum CodingKeys: String, CodingKey {
        case IsFavorite
        case PlayCount
    }
    
    init (isFavorite: Bool, playCount: Int) {
        self.IsFavorite = isFavorite
        self.PlayCount = playCount
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        IsFavorite = try container.decode(Bool.self, forKey: .IsFavorite)
        PlayCount = try container.decode(Int.self, forKey: .PlayCount)
    }
}

struct SongImageInfo: Codable {
    let primary: String?
    
    enum CodingKeys: String, CodingKey {
        case primary = "Primary"
    }
}

struct Song: Codable, Equatable {
    let Id: String
    let Name: String
    let IndexNumber: Int?
    let ParentIndexNumber: Int?
    let Album: String?
    let AlbumId: String?
    let RunTimeTicks: Int
    let Artists: [String]
    let Genres: [String]?
    var UserData: SongUserData
    var coverImageData: Data?
    let DateCreated: String?
    let ImageTags: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case Id
        case Name
        case IndexNumber
        case ParentIndexNumber
        case Album
        case AlbumId
        case RunTimeTicks
        case Artists
        case Genres
        case UserData
        case coverImageData
        case DateCreated
        case ImageTags
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        Id = try container.decode(String.self, forKey: .Id)
        Name = try container.decode(String.self, forKey: .Name)
        IndexNumber = try container.decodeIfPresent(Int.self, forKey: .IndexNumber)
        ParentIndexNumber = try container.decodeIfPresent(Int.self, forKey: .ParentIndexNumber)
        Album = try container.decodeIfPresent(String.self, forKey: .Album)
        AlbumId = try container.decodeIfPresent(String.self, forKey: .AlbumId)
        RunTimeTicks = try container.decode(Int.self, forKey: .RunTimeTicks)
        Artists = try container.decode([String].self, forKey: .Artists)
        Genres = try container.decodeIfPresent([String].self, forKey: .Genres)
        UserData = try container.decode(SongUserData.self, forKey: .UserData)
        coverImageData = try container.decodeIfPresent(Data.self, forKey: .coverImageData)
        DateCreated = try container.decodeIfPresent(String.self, forKey: .DateCreated)
        ImageTags = try container.decodeIfPresent([String: String].self, forKey: .ImageTags)
    }
    
    init(Id: String, Name: String, IndexNumber: Int?, ParentIndexNumber: Int?, Album: String?, AlbumId: String?, RunTimeTicks: Int, Artists: [String], Genres: [String], UserData: SongUserData, DateCreated: String?, ImageTags: [String: String]?) {
        self.Id = Id
        self.Name = Name
        self.IndexNumber = IndexNumber
        self.ParentIndexNumber = ParentIndexNumber
        self.Album = Album
        self.AlbumId = AlbumId
        self.RunTimeTicks = RunTimeTicks
        self.Artists = Artists
        self.Genres = Genres
        self.UserData = UserData
        self.DateCreated = DateCreated
        self.ImageTags = ImageTags
    }
    
    var streamUrl: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey), let accessToken = UserDefaults.standard.string(forKey: accessKey) {
            var streamQuality: String = ""
            if NetworkService.shared.usesWifi {
                streamQuality = StreamQualityService.shared.selectedWifiQuality
            } else {
                streamQuality = StreamQualityService.shared.selectedCellularQuality
            }
            if streamQuality == "Max" {
                return URL(string: "\(serverUrl)/Audio/\(Id)/stream?Static=true&api_key=\(accessToken)")
            } else {
                return URL(string: "\(serverUrl)/Audio/\(Id)/stream?Static=true&MaxStreamingBitrate=\(streamQuality)000&api_key=\(accessToken)")
            }
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
    
    var hasCover: Bool {
        ImageTags?["Primary"] != nil
    }
    
    var coverUrl: URL? {
        if let serverUrl = UserDefaults.standard.string(forKey: serverKey) {
            if hasCover {
                return URL(string: "\(serverUrl)/Items/\(Id)/Images/Primary?maxWidth=\(coverMaxWidth)&maxHeight=\(coverMaxHeight)&quality=\(coverQuality)")
            }
            else {
                return URL(string: "\(serverUrl)/Items/\(AlbumId ?? "Uknown Album")/Images/Primary?maxWidth=\(coverMaxWidth)&maxHeight=\(coverMaxHeight)&quality=\(coverQuality)")
            }
        } else {
            return nil
        }
    }
    
    var albumName: String {
        if let albumName = Album {
            return albumName
        } else {
            return "Unknown Album"
        }
    }
    
    var getAlbumId: String {
        if let id = AlbumId {
            return id
        } else {
            return "0"
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

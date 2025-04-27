//
//  SongsView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

struct SongsView: View {
    let songs: [Song]
    
    let sortingOptions: [String] = ["Name", "Album", "Artist", "DateAdded", "PlayCount"]
    let sortOrder: [String] = ["Ascending", "Descending"]
    
    @State private var selectedSortOption: String = "Name"
    @State private var selectedSortOrder: String = "Ascending"
    @State private var filterText: String = ""
    
    private var filteredSongs: [Song] {
        filterText.isEmpty ? sortedSongs : sortedSongs.filter {
            $0.Name.localizedCaseInsensitiveContains(filterText) ||
            $0.Artists.joined(separator: ", ").localizedCaseInsensitiveContains(filterText) ||
            $0.Album.localizedCaseInsensitiveContains(filterText)
        }
    }
    
    private var sortedSongs: [Song] {
        let sorted: [Song]
        
        switch selectedSortOption {
        case "Name":
            sorted = songs.sorted { $0.Name < $1.Name }
        case "Album":
            sorted = songs.sorted { $0.Album < $1.Album }
        case "Artist":
            sorted = songs.sorted { $0.Artists.joined(separator: ", ") < $1.Artists.joined(separator: ", ") }
        case "DateAdded":
            sorted = songs.sorted { $0.DateCreated ?? "" < $1.DateCreated ?? "" }
        case "PlayCount":
            sorted = songs.sorted { $0.UserData.PlayCount < $1.UserData.PlayCount }
        default:
            sorted = songs
        }
        
        if selectedSortOrder == "Descending" {
            return sorted.reversed()
        } else {
            return sorted
        }
    }
    
    var body: some View {
        List(filteredSongs, id: \.Id) { song in
            Button {
                PlaybackService.shared.playAndBuildQueue(song, songsToPlay: sortedSongs)
            } label: {
                SongRow(song)
            }
            .foregroundStyle(.primary)
        }
        .searchable(text: $filterText, prompt: "Search for a song...")
        .toolbar {
            Menu("Sort by", systemImage: "arrow.up.arrow.down") {
                Menu("Sort order") {
                    Picker("Sort order", selection: $selectedSortOrder) {
                        Text("Ascending").tag("Ascending")
                        Text("Descending").tag("Descending")
                    }
                }
                
                Menu("Sort by") {
                    Picker("Sort by", selection: $selectedSortOption) {
                        Text("Name").tag("Name")
                        Text("Album").tag("Album")
                        Text("Artist").tag("Artist")
                        Text("Date added").tag("DateAdded")
                        Text("Play count").tag("PlayCount")
                    }
                }
            }
            
            IconButton(icon: Image(systemName: "play.fill")) {
                if !songs.isEmpty {
                    PlaybackService.shared.playAndBuildQueue(songs[0], songsToPlay: songs)
                }
            }
            
            IconButton(icon: Image(systemName: "shuffle")) {
                if !songs.isEmpty {
                    let songsToPlay = songs.shuffled()
                    PlaybackService.shared.playAndBuildQueue(songsToPlay[0], songsToPlay: songsToPlay)
                }
            }
        }
    }
}

#Preview {
    SongsView(songs: [])
}

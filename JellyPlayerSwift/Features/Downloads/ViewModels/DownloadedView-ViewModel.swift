//
//  DownloadedView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import Foundation

extension DownloadedView {
    @Observable
    class ViewModel {
        var songs: [Song] = []
        
        func loadDownloadedSongs() async -> [Song] {
            let fileTypes = Set(["mp3", "aac", "m4a", "wav", "ogg", "flac"])
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFiles = (try? FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil))?
                .filter { fileTypes.contains($0.pathExtension.lowercased()) } ?? []

            return await withTaskGroup(of: Song?.self) { group in
                for file in audioFiles {
                    group.addTask {
                        await Song.fromLocalFile(file)
                    }
                }

                var songs: [Song] = []
                for await song in group {
                    if let song = song {
                        songs.append(song)
                    }
                }
                return songs
            }
        }
        
        func loadSongs() {
            Task { @MainActor in
                self.songs = await loadDownloadedSongs()
            }
        }
    }
}

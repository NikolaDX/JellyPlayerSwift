//
//  DownloadService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//
import Foundation
import UIKit

class DownloadService: NSObject, ObservableObject, URLSessionDownloadDelegate {
    static let shared = DownloadService()
    
    @Published var isDownloading = false
    @Published var averageDownloadProgress: Double = 0.0
    @Published var downloads: [Song] = []
    
    private let backgroundSessionIdentifier: String = "com.nikoladx.jellyPlayer.backgroundDownloadSession"
    private lazy var backgroundSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier)
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    private var downloadTasks: [URLSessionTask: Song] = [:]
    private var downloadProgress: [Int: Double] = [:]
    private var completionHandlers: [String: (() -> Void)?] = [:]
    private var downloadingSongs: Set<String> = []
    
    private let fileManager: FileManager = .default
    
    private override init() {
        super.init()
        downloads = loadDownloads() ?? []
    }
    
    func getDocumentsDirectory() -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func downloadSong(_ song: Song) {
        if downloadingSongs.contains(song.Id) { return }
        
        if song.localFilePath != nil { return }
        
        downloadingSongs.insert(song.Id)
        let task = backgroundSession.downloadTask(with: song.downloadURL!)
        downloadTasks[task] = song
        downloadProgress[task.taskIdentifier] = 0
        task.resume()
        Task { @MainActor in
            isDownloading = true
        }
    }
    
    func removeDownload(_ download: Song) {
        let fileURL = download.localFilePath!

        do {
            try fileManager.removeItem(at: fileURL)
            downloads.removeAll(where: { $0.Id == download.Id})
            saveDownloads(songs: downloads)
        } catch {
            print("Error removing file: \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let song = downloadTasks[downloadTask],
              let response = downloadTask.response as? HTTPURLResponse,
              let contentType = response.allHeaderFields["Content-Type"] as? String else {
            return
        }

        let fileExtension = getFileExtension(from: contentType)
        let destination = getDocumentsDirectory().appendingPathComponent("\(song.Id).\(fileExtension)")

        do {
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            try fileManager.moveItem(at: location, to: destination)
            Task { @MainActor in
                self.downloadingSongs.remove(song.Id)
            }
            
            ArtworkService().fetchArtwork(url: song.coverUrl!) { image in
                if let img = image {
                    song.coverImageData = img.pngData()
                }
                self.downloads.append(song)
                self.saveDownloads(songs: self.downloads)
                Task { @MainActor in
                    self.objectWillChange.send()
                }
            }
        } catch {
            print("Error moving downloaded file: \(error.localizedDescription)")
            Task { @MainActor in
                self.isDownloading = false
                self.downloadingSongs.remove(song.Id)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.downloadProgress[downloadTask.taskIdentifier] = progress
            self.averageDownloadProgress = self.downloadProgress.values.reduce(0, +) / Double(self.downloadProgress.count)
        }
    }


    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        downloadTasks.removeValue(forKey: task)
        if downloadTasks.isEmpty {
            Task { @MainActor in
                isDownloading = false;
            }
        }
    }
    
    func getDownloadProgress(for song: Song) -> Double? {
        for (task, downloadedSong) in downloadTasks {
            if downloadedSong == song {
                return downloadProgress[task.taskIdentifier]
            }
        }
        return nil
    }

    func setCompletionHandler(identifier: String, completionHandler: (() -> Void)?) {
        completionHandlers[identifier] = completionHandler
    }

    func callCompletionHandler(identifier: String) {
        completionHandlers[identifier]??()
        completionHandlers[identifier] = nil
    }
    
    func getFileExtension(from mimeType: String) -> String {
        switch mimeType {
        case "audio/mpeg":
            return "mp3"
        case "audio/aac":
            return "aac"
        case "audio/x-m4a":
            return "m4a"
        case "audio/wav":
            return "wav"
        case "audio/ogg":
            return "ogg"
        case "audio/flac":
            return "flac"
        case "audio/opus":
            return "opus"
        default:
            return "mp3"
        }
    }
    
    func saveDownloads(songs: [Song]) {
        do {
            let url = getDocumentsDirectory().appendingPathComponent("downloads.json")
            let data = try JSONEncoder().encode(songs)
            try data.write(to: url)
        } catch {
            print("Error saving downloads: \(error.localizedDescription)")
        }
    }
    
    func loadDownloads() -> [Song]? {
        do {
            let url = getDocumentsDirectory().appendingPathComponent("downloads.json")
            let data = try Data(contentsOf: url)
            let downloadedSongs = try JSONDecoder().decode([Song].self, from: data)
            return downloadedSongs
        } catch {
            print("Error loading downloads: \(error.localizedDescription)")
        }
        return nil
    }
}

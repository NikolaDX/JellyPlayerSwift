//
//  RecommendationService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 8. 7. 2026..
//

import AVFAudio
import CoreML
import Foundation

class RecommendationService {
    static let shared = RecommendationService()
    var personalizedModel: MLModel?
    
    private let favoriteBoost: Double = 0.3
    private let genreBoost: Double = 3.0
    private let defaultEnergy: Double = 0.5
    private let energyDifferencePenalty: Double = 4.5
    
    private var modelURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("UserPersonalizedRecommender.mlmodelc")
    }
    
    private init() {
        loadModel()
        NotificationCenter.default.addObserver(self, selector: #selector(loadModel), name: NSNotification.Name("ModelDidUpdate"), object: nil)
    }
    
    @objc func loadModel() {
        do {
            self.personalizedModel = try MLModel(contentsOf: modelURL)
            print("Loaded personalized model.")
        } catch {
            print("No personalized model found yet. User needs to generate more data.")
        }
    }
    
    func score(toScore songs: [Song], request: RecommendationRequest) -> [(song: Song, score: Double)] {
        guard let model = personalizedModel else {
            return []
        }
        
        let currentDate = Date()
        let currentHour = Calendar.current.component(.hour, from: currentDate)
        let latitude = LocationService.shared.location?.latitude ?? 0.0
        let longitude = LocationService.shared.location?.longitude ?? 0.0
        
        let audioOutput = AudioContextService.shared.output
        let audioVolume = AudioContextService.shared.volume
        
        var networkType: NetworkType = .offline
        
        if !NetworkService.shared.isConnected {
            networkType = .offline
        } else if NetworkService.shared.usesWifi {
            networkType = .wifi
        } else {
            networkType = .cellular
        }
        
        var playlistGenres = Set<String>()
        var averagePlaylistEnergy: Double = 0.5
        
        if case .playlist(let playlistSongs) = request, !playlistSongs.isEmpty {
            var totalEnergy = 0.0
            for pSong in playlistSongs {
                if let genres = pSong.Genres {
                    playlistGenres.formUnion(genres)
                }
                totalEnergy += AudioAnalysisService.shared.getEnergy(for: pSong.Id) ?? defaultEnergy
            }
            averagePlaylistEnergy = totalEnergy / Double(playlistSongs.count)
        }
        
        var scoredSongs: [(song: Song, score: Double)] = []
        let downloadedSongs = DownloadService.shared.downloads
        
        for song in songs {
            let isDownloaded = downloadedSongs.contains(song)
            if networkType == .offline && !isDownloaded {
                scoredSongs.append((song, -.infinity))
                continue
            }
            
            let energy = AudioAnalysisService.shared.getEnergy(for: song.Id) ?? defaultEnergy
            
            let input = RecommenderFeatures.inputDictionary(
                for: song,
                currentHour: currentHour,
                latitude: latitude,
                longitude: longitude,
                activity: MotionService.shared.activity.rawValue,
                audioOutput: audioOutput,
                audioVolume: audioVolume,
                timeOfDay: TimeOfDay(hour: currentHour),
                networkType: networkType,
                dayOfWeek: Calendar.current.component(.weekday, from: currentDate),
                energy: energy,
                duration: song.durationInSeconds
            )
            
            var score = -Double.infinity
            
            do {
                let provider = try MLDictionaryFeatureProvider(dictionary: input)
                let prediction = try model.prediction(from: provider)
                score = prediction
                    .featureValue(for: RecommenderFeatures.targetColumn)?
                    .doubleValue ?? -Double.infinity
            } catch {
                print("Model prediction failed for \(song.Name): \(error)")
            }
            
            switch request {
            case .regular:
                if song.UserData.IsFavorite { score += favoriteBoost }
            case .queue(let queue):
                if queue.contains(song) {
                    score = -.infinity
                }
                
                if song.Id == queue.last?.Id {
                    score = -.infinity
                }
                
                let genreProfile = queueGenreProfile(for: queue)
                score += genreAffinityScore(for: song, profile: genreProfile)
                
                if song.UserData.IsFavorite {
                    score += favoriteBoost
                }
                
                let targetEnergy = recentAverageEnergy(for: queue)
                let difference = abs(targetEnergy - energy)

                switch difference {
                case 0..<0.1:
                    score += 3
                case 0.1..<0.2:
                    score += 2
                case 0.2..<0.35:
                    score += 1
                default:
                    score -= difference * energyDifferencePenalty
                }
            case .shuffle(let currentSong):
                if let genres = song.Genres, let currentGenres = currentSong.Genres {
                    if !Set(genres).intersection(currentGenres).isEmpty {
                        score += genreBoost
                    }
                }
                
                let currentEnergy = AudioAnalysisService.shared.getEnergy(for: currentSong.Id) ?? 0.5
                let desiredEnergy = min(currentEnergy + 0.05, 1.0)
                let difference = abs(desiredEnergy - energy)

                score -= difference * 4
                
                score += Double.random(in: -1...1)
            case .playlist(let playlistSongs):
                if playlistSongs.contains(song) {
                    score -= .infinity
                } else {
                    if let genres = song.Genres, !Set(genres).intersection(playlistGenres).isEmpty {
                        score += genreBoost
                    }
                    
                    let energyDifference = abs(averagePlaylistEnergy - energy)
                    score -= (energyDifference * energyDifferencePenalty)
                    
                    if song.UserData.IsFavorite {
                        score += favoriteBoost
                    }
                }
            }
            
            scoredSongs.append((song, score))
        }
        
        return scoredSongs
    }
    
    private func queueGenreProfile(for queue: [Song], lookback: Int = 6) -> [String: Double] {
        var profile: [String: Double] = [:]
        let recentSongs = queue.suffix(lookback)
        let count = recentSongs.count
        guard count > 0 else { return profile }
        
        for (index, song) in recentSongs.enumerated() {
            let recencyWeight = Double(index + 1) / Double(count)
            guard let genres = song.Genres else { continue }
            for genre in genres {
                profile[genre, default: 0] += recencyWeight
            }
        }
        
        return profile
    }

    private func genreAffinityScore(for song: Song, profile: [String: Double]) -> Double {
        guard let genres = song.Genres, !genres.isEmpty, !profile.isEmpty else { return 0 }
        
        let totalWeight = profile.values.reduce(0, +)
        guard totalWeight > 0 else { return 0 }
        
        let matchedWeight = genres.reduce(0.0) { $0 + (profile[$1] ?? 0) }
        let matchRatio = matchedWeight / totalWeight
        
        return matchRatio * genreBoost
    }

    private func recentAverageEnergy(for queue: [Song], lookback: Int = 6) -> Double {
        let recentSongs = queue.suffix(lookback)
        guard !recentSongs.isEmpty else { return defaultEnergy }
        let energies = recentSongs.map { AudioAnalysisService.shared.getEnergy(for: $0.Id) ?? defaultEnergy }
        return energies.reduce(0, +) / Double(energies.count)
    }
    
    func getRecommendations(from availableSongs: [Song], request: RecommendationRequest) throws -> [Song] {
        guard personalizedModel != nil else {
            throw RecommendationError.modelUnavailable
        }
        
        return score(
            toScore: availableSongs,
            request: request
        )
            .sorted(by: { $0.score > $1.score })
            .map(\.song)
    }
    
    func smartShuffle(songs: [Song], currentSong: Song?) throws -> [Song] {
        try getRecommendations(from: songs, request: .shuffle(currentSong: currentSong ?? songs[0]))
    }
}

//
//  AudioAnalysisService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 26. 7. 2026..
//

import AVFoundation
import Foundation

final class AudioAnalysisService {
    static let shared = AudioAnalysisService()
    
    private var totalSquareSum: Float = 0.0
    private var totalSampleCount: Int64 = 0
    private var currentSongId: String?
    
    private init() {
        loadCacheFromDisk()
    }
    
    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("song_energy_cache.json")
    }
    
    private let queue = DispatchQueue(label: "com.jellyplayer.energycache", attributes: .concurrent)
    
    private var cache: [String: Double] = [:]
    
    var currentEnergy: Double {
        guard totalSampleCount > 0 else { return 0.0 }
        let rms = sqrt(totalSquareSum / Float(totalSampleCount))
        return min(Double(rms * 2.5), 1.0)
    }
    
    func reset(for songId: String) {
        totalSquareSum = 0.0
        totalSampleCount = 0
        currentSongId = songId
    }
    
    func finalizeAndSave() {
        guard let id = currentSongId, totalSampleCount > 0 else { return }
        
        let finalEnergy = currentEnergy
        print("Final streaming energy for song \(id): \(finalEnergy)")
        
        save(energy: finalEnergy, for: currentSongId!)
        
        currentSongId = nil
    }
    
    func attachTap(to item: AVPlayerItem, for song: Song) {
        reset(for: song.Id)
        
        Task { @MainActor in
            do {
                guard let audioTrack = try await item.asset.loadTracks(withMediaType: .audio).first else { return }
                
                var callbacks = MTAudioProcessingTapCallbacks(
                    version: kMTAudioProcessingTapCallbacksVersion_0,
                    clientInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                    init: { tap, clientInfo, tapStorageOut in
                        tapStorageOut.pointee = clientInfo
                    },
                    finalize: nil,
                    prepare: nil,
                    unprepare: nil,
                    process: { tap, numberFrames, flags, bufferListInOut, numberFramesOut, flagsOut in
                        let status = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut, flagsOut, nil, numberFramesOut)
                        if status == noErr {
                            let clientInfo = MTAudioProcessingTapGetStorage(tap)
                            let analyzer = Unmanaged<AudioAnalysisService>.fromOpaque(clientInfo).takeUnretainedValue()
                            analyzer.processBuffers(bufferListInOut)
                        }
                    }
                )
                
                var newTap: MTAudioProcessingTap?
                let status = MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks, kMTAudioProcessingTapCreationFlag_PostEffects, &newTap)
                
                if status == noErr, let validTap = newTap {
                    let mixParams = AVMutableAudioMixInputParameters(track: audioTrack)
                    mixParams.audioTapProcessor = validTap
                    
                    let audioMix = AVMutableAudioMix()
                    audioMix.inputParameters = [mixParams]
                    
                    item.audioMix = audioMix
                }
            } catch {
                print("Failed to attach tap: \(error)")
            }
        }
    }
    
    fileprivate func processBuffers(_ bufferListInOut: UnsafeMutablePointer<AudioBufferList>) {
        let buffers = UnsafeMutableAudioBufferListPointer(bufferListInOut)
        
        for buffer in buffers {
            guard let data = buffer.mData else { continue }
            
            let floatData = data.assumingMemoryBound(to: Float.self)
            let frameLength = Int(buffer.mDataByteSize) / MemoryLayout<Float>.size
            
            var localSquareSum: Float = 0.0
            for i in 0..<frameLength {
                let sample = floatData[i]
                localSquareSum += sample * sample
            }
            
            self.totalSquareSum += localSquareSum
            self.totalSampleCount += Int64(frameLength)
        }
    }
    
    private func loadCacheFromDisk() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            cache = try JSONDecoder().decode([String: Double].self, from: data)
            print("Loaded \(cache.count) cached song energies.")
        } catch {
            print("Failed to read energy cache: \(error)")
        }
    }
    
    func save(energy: Double, for songId: String) {
        queue.async(flags: .barrier) {
            self.cache[songId] = energy
            
            do {
                let data = try JSONEncoder().encode(self.cache)
                try data.write(to: self.fileURL, options: .atomic)
                print("Saved energy \(energy) for song \(songId)")
            } catch {
                print("Failed to write energy cache to disk: \(error)")
            }
        }
    }
    
    func getEnergy(for songId: String) -> Double? {
        queue.sync {
            return cache[songId]
        }
    }
    
    func getAllCachedEnergies() -> [String: Double] {
        queue.sync {
            return cache
        }
    }
}

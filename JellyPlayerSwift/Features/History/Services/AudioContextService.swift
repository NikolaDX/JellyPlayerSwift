//
//  AudioContextService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 22. 7. 2026..
//

import AVFAudio
import Foundation

@Observable
class AudioContextService {
    static let shared = AudioContextService()
    
    private(set) var output: AudioOutput = .speaker
    private(set) var volume: Float = 0
    
    private let session = AVAudioSession.sharedInstance()
    
    private var volumeObservation: NSKeyValueObservation?
    
    private init() {}
    
    func start() {
        updateOutput()
        updateVolume()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(routeChanged),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        
        volumeObservation = session.observe(
            \.outputVolume,
             options: [.initial, .new]
        ) { [weak self] session, _ in
            DispatchQueue.main.async {
                self?.volume = session.outputVolume
            }
        }
    }
    
    func stop() {
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        
        volumeObservation?.invalidate()
    }
    
    @objc private func routeChanged(_ notification: Notification) {
        updateOutput()
    }
    
    private func updateOutput() {
        let outputs = session.currentRoute.outputs
        
        guard let output = outputs.first else {
            self.output = .other
            return
        }
        
        switch output.portType {
        case .builtInSpeaker, .builtInReceiver:
            self.output = .speaker
        case .headphones:
            self.output = .headphones
        case .bluetoothLE, .bluetoothHFP, .bluetoothA2DP:
            self.output = .bluetooth
        case .carAudio:
            self.output = .car
        case .airPlay:
            self.output = .airplay
        case .usbAudio:
            self.output = .usb
        
        default:
            self.output = .other
        }
    }
    
    private func updateVolume() {
        volume = session.outputVolume
    }
}

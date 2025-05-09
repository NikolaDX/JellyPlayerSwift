//
//  StreamQualityService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/3/25.
//

import Foundation

class StreamQualityService: ObservableObject {
    static let shared = StreamQualityService()
    
    @Published var selectedWifiQuality: String {
        didSet {
            UserDefaults.standard.set(selectedWifiQuality, forKey: wifiQualityKey)
        }
    }
    
    @Published var selectedCellularQuality: String {
        didSet {
            UserDefaults.standard.set(selectedCellularQuality, forKey: cellularQualityKey)
        }
    }
    
    let availableQualityOptions: [String] = ["Max", "320", "256", "128"]
    
    private init() {
        selectedWifiQuality = UserDefaults.standard.string(forKey: wifiQualityKey) ?? "320"
        selectedCellularQuality = UserDefaults.standard.string(forKey: cellularQualityKey) ?? "320"
    }
}

//
//  NetworkService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/2/25.
//

import Foundation
import Network

class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkService")
    
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var usesWifi: Bool = false
    @Published private(set) var usesCellular: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.usesWifi = path.usesInterfaceType(.wifi)
                self?.usesCellular = path.usesInterfaceType(.cellular)
            }
        }
        monitor.start(queue: queue)
    }
}

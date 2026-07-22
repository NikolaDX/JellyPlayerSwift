//
//  JellyPlayerSwiftApp.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

@main
struct JellyPlayerSwiftApp: App {
    
    init() {
        _ = ListeningService.shared
        AudioContextService.shared.start()
        MotionService.shared.start()
        LocationService.shared.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

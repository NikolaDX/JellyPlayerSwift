//
//  ListeningService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 22. 7. 2026..
//

import Combine
import Foundation

final class ListeningService {
    static let shared = ListeningService()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        observePlayback()
    }
    
    private func observePlayback() {
        NotificationCenter.default.publisher(for: .songPlaybackFinished)
            .compactMap { $0.object as? Song }
            .sink { song in
                HistoryService.shared.logEvent(for: song)
                TrainingSchedulerService.shared.newEventAdded()
            }
            .store(in: &cancellables)
    }
}

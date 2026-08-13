//
//  TrainingSchedulerService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 22. 7. 2026..
//

import Foundation

final class TrainingSchedulerService {
    static let shared = TrainingSchedulerService()
    
    private var eventCounter: Int {
        get {
            UserDefaults.standard.integer(forKey: "eventsSinceTraining")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "eventsSinceTraining")
        }
    }
    private let minimumEvents = 5
    
    private init() {}
    
    func newEventAdded() {
        eventCounter += 1
        if eventCounter >= minimumEvents {
            train()
        }
    }
    
    private func train() {
        eventCounter = 0
        
        Task.detached(priority: .background) {
            let history = HistoryService.shared.fetchLocalHistory()
            await ModelTrainingService.shared.trainModel(
                with: history,
                using: .randomForest
            )
        }
    }
}

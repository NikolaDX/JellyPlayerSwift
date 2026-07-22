//
//  MotionService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 22. 7. 2026..
//

import CoreMotion
import Foundation

@Observable
class MotionService {
    static let shared = MotionService()
    
    private let activityManager = CMMotionActivityManager()
    
    private(set) var activity: UserActivity = .unknown
    
    private init() {}
    
    func start() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            return
        }
        
        activityManager.startActivityUpdates(to: .main) { [weak self] motionActivity in
            guard let self, let motionActivity else { return }
            
            if motionActivity.walking {
                activity = .walking
            } else if motionActivity.running {
                activity = .running
            } else if motionActivity.cycling {
                activity = .cycling
            } else if motionActivity.automotive {
                activity = .automotive
            } else if motionActivity.stationary {
                activity = .stationary
            } else {
                activity = .unknown
            }
        }
    }
    
    func stop() {
        activityManager.stopActivityUpdates()
    }
}

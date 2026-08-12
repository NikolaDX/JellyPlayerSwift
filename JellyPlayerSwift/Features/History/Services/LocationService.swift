//
//  LocationService.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 13. 7. 2026..
//

import CoreLocation
import Foundation

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let manager = CLLocationManager()
    
    private(set) var location: CLLocationCoordinate2D?
    
    @Published var error: Error?
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100
    }
    
    var isEnabled: Bool {
        UserDefaults.standard.object(forKey: locationEnabled) as? Bool ?? true
    }
    
    func start() {
        guard isEnabled else {
            stop()
            return
        }
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            error = CLError(.denied)
        case .denied:
            error = CLError(.denied)
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorized:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func stop() {
        manager.stopUpdatingLocation()
        location = nil
    }
    
    func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: locationEnabled)
        
        if enabled {
            start()
        } else {
            stop()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isEnabled else {
            stop()
            return
        }
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.location = location.coordinate
        print(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
        print("Location error: \(error.localizedDescription)")
    }
}

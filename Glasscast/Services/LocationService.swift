//
//  LocationService.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import Foundation
import CoreLocation
import Combine

enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnavailable
    case failed
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied: return "Location permission denied. Please enable in Settings."
        case .locationUnavailable: return "Unable to determine your location."
        case .failed: return "Location service failed."
        case .cancelled: return "Request cancelled."
        }
    }
}

#if os(iOS)
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // CRITICAL: Make cancellable to prevent concurrent calls
    private var taskCancellable: AnyCancellable?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        // Prevent concurrent calls
        if taskCancellable != nil {
            throw LocationError.cancelled
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: LocationError.cancelled)
                return
            }
            
            self.taskCancellable = Just(())
                .delay(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .sink { _ in
                    self.performLocationRequest(continuation: continuation)
                }
        }
    }
    
    private func performLocationRequest(continuation: CheckedContinuation<CLLocation, Error>) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationContinuation = continuation
            requestLocationPermission()
        case .restricted, .denied:
            continuation.resume(throwing: LocationError.permissionDenied)
        case .authorizedAlways, .authorizedWhenInUse:
            locationContinuation = continuation
            locationManager.requestLocation()
        @unknown default:
            continuation.resume(throwing: LocationError.failed)
        }
        taskCancellable = nil
    }
    
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = manager.authorizationStatus
            
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                self?.locationContinuation.map { $0.resume(returning: CLLocation()) } // Temp location or refetch
            } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
                self?.locationContinuation?.resume(throwing: LocationError.permissionDenied)
            }
            self?.locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async { [weak self] in
            guard let location = locations.first else {
                self?.locationContinuation?.resume(throwing: LocationError.locationUnavailable)
                self?.locationContinuation = nil
                return
            }
            
            self?.locationContinuation?.resume(returning: location)
            self?.locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.locationContinuation?.resume(throwing: LocationError.failed)
            self?.locationContinuation = nil
        }
    }
}
#else
// macOS fallback unchanged
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private override init() { super.init() }
    
    func requestLocationPermission() { print("Location not available") }
    func getCurrentLocation() async throws -> CLLocation {
        throw LocationError.locationUnavailable
    }
}
#endif


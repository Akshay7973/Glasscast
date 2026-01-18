//
//  SettingsViewModel.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

// MARK: - ViewModels/SettingsViewModel.swift
import Foundation
import SwiftUI
import Combine
import CoreLocation

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("temperatureUnit") var temperatureUnit: String = TemperatureUnit.celsius.rawValue
    @Published var errorMessage: String?
    @Published var locationAuthStatus: CLAuthorizationStatus = .notDetermined
    
    private let supabase = SupabaseService.shared
    private let locationService = LocationService.shared
    
    init() {
        locationAuthStatus = locationService.authorizationStatus
    }
    
    var currentUnit: TemperatureUnit {
        TemperatureUnit(rawValue: temperatureUnit) ?? .celsius
    }
    
    var userEmail: String {
        supabase.getCurrentUser()?.email ?? "Not logged in"
    }
    
    var locationStatusText: String {
        switch locationAuthStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "Enabled"
        case .denied, .restricted:
            return "Disabled"
        case .notDetermined:
            return "Not Set"
        @unknown default:
            return "Unknown"
        }
    }
    
    var locationStatusColor: Color {
        switch locationAuthStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .gray
        }
    }
    
    func toggleUnit() {
        temperatureUnit = currentUnit == .celsius ? TemperatureUnit.fahrenheit.rawValue : TemperatureUnit.celsius.rawValue
    }
    
    func requestLocationPermission() {
        locationService.requestLocationPermission()
        // Update status after a short delay
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            locationAuthStatus = locationService.authorizationStatus
        }
    }
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func signOut() async {
        do {
            try await supabase.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

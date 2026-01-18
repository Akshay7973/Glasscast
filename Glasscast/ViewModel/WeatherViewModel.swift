//
//  WeatherViewModel.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var currentWeather: Weather?
    @Published var forecast: [Weather] = []
    @Published var selectedCity: City?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherService.shared
    private let locationService = LocationService.shared
    
    @AppStorage("temperatureUnit") private var tempUnit: String = "metric"
    
    private var currentUnit: TemperatureUnit {
        TemperatureUnit(rawValue: tempUnit) ?? .celsius
    }
    
    func fetchWeatherForCurrentLocation() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let location = try await locationService.getCurrentLocation()
            await fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func fetchWeather(lat: Double, lon: Double) async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let current = weatherService.fetchCurrentWeather(lat: lat, lon: lon, units: currentUnit)
            async let forecastData = weatherService.fetch5DayForecast(lat: lat, lon: lon, units: currentUnit)
            
            currentWeather = try await current
            forecast = try await forecastData
            
            print("Fetched \(forecast.count) forecast days")
        } catch {
            errorMessage = error.localizedDescription
            print("Weather fetch error: \(error)")
        }
        
        isLoading = false
    }
    
    func refresh() async {
        guard let city = selectedCity else {
            await fetchWeatherForCurrentLocation()
            return
        }
        await fetchWeather(lat: city.lat, lon: city.lon)
    }
}

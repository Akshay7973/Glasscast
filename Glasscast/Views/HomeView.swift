//
//  HomeView.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var locationService = LocationService.shared  // Add this
    @AppStorage("temperatureUnit") private var tempUnit: String = "metric"
    @State private var hasLoadedInitialWeather = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if #available(iOS 18.0, *) {
                    MeshGradient(width: 3, height: 3, points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [0.5, 0.5], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ], colors: [
                        .teal, .blue, .indigo,
                        .blue, .purple, .purple,
                        .indigo, .purple, .black
                    ])
                    .ignoresSafeArea()
                } else {
                    LinearGradient(colors: [.blue.opacity(0.6), .purple.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isLoading {
                            VStack(spacing: 15) {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(1.5)
                                Text("Loading weather...")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.top, 100)
                        } else if let error = viewModel.errorMessage {
                            errorView(error)
                        } else if let weather = viewModel.currentWeather {
                            weatherContent(weather)
                        } else {
                            emptyState
                        }
                        
                        if !searchViewModel.favoriteCities.isEmpty {
                            favoriteCitiesView
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationTitle(viewModel.selectedCity?.cityName ?? "Weather")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if !hasLoadedInitialWeather {
                    hasLoadedInitialWeather = true
                    Task {
                        await fetchWeatherForCurrentLocation()
                    }
                }
            }
            .onChange(of: locationService.authorizationStatus) {
                if locationService.authorizationStatus == .authorizedWhenInUse ||
                   locationService.authorizationStatus == .authorizedAlways {
                    Task {
                        await fetchWeatherForCurrentLocation()
                    }
                }
            }
        }
    }
    
    // MARK: - Location + Weather Flow
    private func fetchWeatherForCurrentLocation() async {
        // Request permission if needed
        locationService.requestLocationPermission()
        
        do {
            let location = try await locationService.getCurrentLocation()
            await viewModel.fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        } catch {
            print("Location error: \(error)")
            // viewModel can handle this in its error state
        }
    }
    
    private func refreshWeather() {
        Task {
            if let city = viewModel.selectedCity {
                await viewModel.fetchWeather(lat: city.lat, lon: city.lon)
            } else {
                await fetchWeatherForCurrentLocation()
            }
        }
    }
    
    private func weatherContent(_ weather: Weather) -> some View {
        VStack(spacing: 20) {
            GlassCard {
                VStack(spacing: 10) {
                    // Dynamic weather icon
                    Image(systemName: WeatherIcon.from(condition: weather.weatherCondition.main).rawValue)
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: .white.opacity(0.3), radius: 10)
                    
                    Text("\(Int(weather.temp))\(tempUnit == "metric" ? "°C" : "°F")")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(weather.weatherCondition.main)
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text("High")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(Int(weather.tempMax))°")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        VStack {
                            Text("Low")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(Int(weather.tempMin))°")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            
            if !viewModel.forecast.isEmpty {
                forecastView
            }
        }
    }
    
    private var forecastView: some View {
        VStack(alignment: .leading) {
            Text("5-Day Forecast")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.forecast) { day in
                        ForecastCardView(weather: day, unit: tempUnit)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 15) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                Text("No weather data")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Tap button to use your location or search for a city")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                Button("Enable Location") {
                    Task { await fetchWeatherForCurrentLocation() }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
    
    private func errorView(_ error: String) -> some View {
        GlassCard {
            VStack(spacing: 15) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                Text("Error")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(error)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                Button("Retry Location") {
                    Task { await fetchWeatherForCurrentLocation() }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
    
    private var favoriteCitiesView: some View {
        VStack(alignment: .leading) {
            Text("Favorites")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ForEach(searchViewModel.favoriteCities) { city in
                Button(action: {
                    viewModel.selectedCity = city
                    Task {
                        await viewModel.fetchWeather(lat: city.lat, lon: city.lon)
                    }
                }) {
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(city.cityName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                if let country = city.countryCode {
                                    Text(country)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - WeatherIcon Enum (Add globally)
enum WeatherIcon: String {
    case clear = "sun.max.fill"
    case clouds = "cloud.fill"
    case rain = "cloud.rain.fill"
    case drizzle = "cloud.drizzle.fill"
    case thunderstorm = "cloud.bolt.rain.fill"
    case snow = "cloud.snow.fill"
    case mist = "cloud.fog.fill"
    case defaultIcon = "cloud.sun.rain.fill"
    
    static func from(condition: String) -> WeatherIcon {
        switch condition.lowercased() {
        case "clear": return .clear
        case "cloud", "clouds", "partly cloudy": return .clouds
        case "rain": return .rain
        case "drizzle": return .drizzle
        case "thunderstorm": return .thunderstorm
        case "snow": return .snow
        case "mist", "fog", "haze", "smoke", "dust", "ash": return .mist
        default: return .defaultIcon
        }
    }
}


//
//#Preview {
//    HomeView()
//}

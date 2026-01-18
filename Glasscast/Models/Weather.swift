//
//  Weather.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import Foundation

// MARK: - Models/Weather.swift
struct Weather: Identifiable {
    var id: String { "\(dt)" } // Use timestamp as unique ID
    let dt: TimeInterval
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let weatherCondition: WeatherCondition
    let windSpeed: Double
    let clouds: Int
    let pop: Double? // Probability of precipitation
    
    // Manual initializer for creating Weather objects
    init(dt: TimeInterval, temp: Double, feelsLike: Double, tempMin: Double, tempMax: Double, pressure: Int, humidity: Int, weatherCondition: WeatherCondition, windSpeed: Double, clouds: Int, pop: Double? = nil) {
        self.dt = dt
        self.temp = temp
        self.feelsLike = feelsLike
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.pressure = pressure
        self.humidity = humidity
        self.weatherCondition = weatherCondition
        self.windSpeed = windSpeed
        self.clouds = clouds
        self.pop = pop
    }
    
    var date: Date {
        Date(timeIntervalSince1970: dt)
    }
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct WeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
    
    var iconName: String {
        // Map OpenWeather icons to SF Symbols
        switch icon {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.rain.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
}

// MARK: - Response Models for OpenWeather API
struct CurrentWeatherResponse: Codable {
    let coord: Coordinates
    let weather: [WeatherCondition]
    let main: MainWeatherData
    let wind: Wind
    let clouds: Clouds
    let dt: TimeInterval
    let name: String
}

struct ForecastResponse: Codable {
    let list: [ForecastItem]
}

struct ForecastItem: Codable {
    let dt: TimeInterval
    let main: MainWeatherData
    let weather: [WeatherCondition]
    let wind: Wind
    let clouds: Clouds
    let pop: Double
}

struct MainWeatherData: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}

struct Wind: Codable {
    let speed: Double
}

struct Clouds: Codable {
    let all: Int
}

struct Coordinates: Codable {
    let lat: Double
    let lon: Double
}

struct GeocodingResponse: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}

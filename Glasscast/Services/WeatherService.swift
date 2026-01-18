//
//  WeatherService.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import Foundation

enum WeatherError: LocalizedError {
    case invalidURL
    case networkError
    case decodingError
    case apiError(String)
    case noCitiesFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .networkError:
            return "Network connection failed."
        case .decodingError:
            return "Failed to decode weather data."
        case .apiError(let message):
            return "API Error: \(message)"
        case .noCitiesFound:
            return "No cities found matching your search."
        }
    }
}

final class WeatherService {
    static let shared = WeatherService()
    
    private init() {}
    
    // MARK: - Current Weather
    
    func fetchCurrentWeather(lat: Double, lon: Double, units: TemperatureUnit = .celsius) async throws -> Weather {
        let urlString = "\(AppConstants.openWeatherBaseURL)/weather?lat=\(lat)&lon=\(lon)&units=\(units.rawValue)&appid=\(AppConstants.openWeatherAPIKey)"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherError.networkError
            }
            
            guard httpResponse.statusCode == 200 else {
                throw WeatherError.apiError("Status code: \(httpResponse.statusCode)")
            }
            
            let weatherResponse = try JSONDecoder().decode(CurrentWeatherResponse.self, from: data)
            
            return Weather(
                dt: weatherResponse.dt,
                temp: weatherResponse.main.temp,
                feelsLike: weatherResponse.main.feelsLike,
                tempMin: weatherResponse.main.tempMin,
                tempMax: weatherResponse.main.tempMax,
                pressure: weatherResponse.main.pressure,
                humidity: weatherResponse.main.humidity,
                weatherCondition: weatherResponse.weather.first!,
                windSpeed: weatherResponse.wind.speed,
                clouds: weatherResponse.clouds.all,
                pop: nil
            )
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw WeatherError.decodingError
        } catch {
            print("Network error: \(error)")
            throw WeatherError.networkError
        }
    }
    
    // MARK: - 5-Day Forecast
    
    func fetch5DayForecast(lat: Double, lon: Double, units: TemperatureUnit = .celsius) async throws -> [Weather] {
            let urlString = "\(AppConstants.openWeatherBaseURL)/forecast?lat=\(lat)&lon=\(lon)&units=\(units.rawValue)&appid=\(AppConstants.openWeatherAPIKey)"
            
            print("🌤️ Fetching forecast from: \(urlString)")
            
            guard let url = URL(string: urlString) else {
                throw WeatherError.invalidURL
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw WeatherError.networkError
                }
                
                print("📡 Forecast API Status: \(httpResponse.statusCode)")
                
                guard httpResponse.statusCode == 200 else {
                    throw WeatherError.apiError("Status code: \(httpResponse.statusCode)")
                }
                
                let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
                print("📊 Total forecast items from API: \(forecastResponse.list.count)")
                
                // Group forecasts by day and get one per day
                let calendar = Calendar.current
                var dailyForecasts: [Weather] = []
                var seenDays: Set<String> = []
                
                for item in forecastResponse.list {
                    let date = Date(timeIntervalSince1970: item.dt)
                    let dayString = calendar.startOfDay(for: date).timeIntervalSince1970.description
                    
                    // Take first forecast for each day, limit to 5 days
                    if !seenDays.contains(dayString) && dailyForecasts.count < 5 {
                        seenDays.insert(dayString)
                        let weather = Weather(
                            dt: item.dt,
                            temp: item.main.temp,
                            feelsLike: item.main.feelsLike,
                            tempMin: item.main.tempMin,
                            tempMax: item.main.tempMax,
                            pressure: item.main.pressure,
                            humidity: item.main.humidity,
                            weatherCondition: item.weather.first!,
                            windSpeed: item.wind.speed,
                            clouds: item.clouds.all,
                            pop: item.pop
                        )
                        dailyForecasts.append(weather)
                        print("✅ Added forecast for day \(dailyForecasts.count): \(weather.dayName)")
                    }
                    
                    if dailyForecasts.count >= 5 {
                        break
                    }
                }
                
                print("📅 Final forecast count: \(dailyForecasts.count)")
                return dailyForecasts
            } catch let error as DecodingError {
                print("❌ Decoding error: \(error)")
                throw WeatherError.decodingError
            } catch {
                print("❌ Network error: \(error)")
                throw WeatherError.networkError
            }
        }
        
    
    // MARK: - Search Cities
    
    func searchCities(query: String) async throws -> [City] {
        let urlString = "\(AppConstants.openWeatherGeoURL)/direct?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&limit=5&appid=\(AppConstants.openWeatherAPIKey)"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherError.networkError
            }
            
            guard httpResponse.statusCode == 200 else {
                throw WeatherError.apiError("Status code: \(httpResponse.statusCode)")
            }
            
            let geocodingResults = try JSONDecoder().decode([GeocodingResponse].self, from: data)
            
            guard !geocodingResults.isEmpty else {
                throw WeatherError.noCitiesFound
            }
            
            return geocodingResults.map { result in
                City(
                    cityName: result.name,
                    countryCode: result.country,
                    lat: result.lat,
                    lon: result.lon
                )
            }
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw WeatherError.decodingError
        } catch {
            print("Network error: \(error)")
            throw WeatherError.networkError
        }
    }
}

// Temperature unit enum
enum TemperatureUnit: String, Codable {
    case celsius = "metric"
    case fahrenheit = "imperial"
    
    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}

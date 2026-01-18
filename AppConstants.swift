//
//  AppConstants.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import Foundation
import Foundation

enum AppConstants {
    static let supabaseURL: String = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let url = config["SUPABASE_URL"] as? String else {
            fatalError("SUPABASE_URL not found in Config.plist")
        }
        return url
    }()
    
    static let supabaseAnonKey: String = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let key = config["SUPABASE_ANON_KEY"] as? String else {
            fatalError("SUPABASE_ANON_KEY not found in Config.plist")
        }
        return key
    }()
    
    static let openWeatherAPIKey: String = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let key = config["OPENWEATHER_API_KEY"] as? String else {
            fatalError("OPENWEATHER_API_KEY not found in Config.plist")
        }
        return key
    }()
    
    static let openWeatherBaseURL = "https://api.openweathermap.org/data/2.5"
    static let openWeatherGeoURL = "https://api.openweathermap.org/geo/1.0"
}

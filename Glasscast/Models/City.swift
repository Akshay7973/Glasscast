//
//  City.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//
import Foundation

struct City: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID?
    let cityName: String
    let countryCode: String?
    let lat: Double
    let lon: Double
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case cityName = "city_name"
        case countryCode = "country_code"
        case lat
        case lon
        case createdAt = "created_at"
    }
    
    // Initializer for search results (no user_id yet)
    init(id: UUID = UUID(), userId: UUID? = nil, cityName: String, countryCode: String?, lat: Double, lon: Double, createdAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.cityName = cityName
        self.countryCode = countryCode
        self.lat = lat
        self.lon = lon
        self.createdAt = createdAt
    }
    
    var displayName: String {
        if let country = countryCode {
            return "\(cityName), \(country)"
        }
        return cityName
    }
}


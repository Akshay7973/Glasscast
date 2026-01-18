//
//  SearchViewModel.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

// MARK: - ViewModels/SearchViewModel.swift
import Foundation
import SwiftUI
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [City] = []
    @Published var favoriteCities: [City] = []
    @Published var recentSearches: [City] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherService.shared
    private let supabase = SupabaseService.shared
    private var searchTask: Task<Void, Never>?
    
    @AppStorage("recentSearches") private var recentSearchesData: Data = Data()
    
    init() {
        Task {
            await fetchFavorites()
            loadRecentSearches()
        }
    }
    
    func search() {
        searchTask?.cancel()
        
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            
            guard !Task.isCancelled else { return }
            
            isSearching = true
            
            do {
                searchResults = try await weatherService.searchCities(query: searchQuery)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isSearching = false
        }
    }
    
    func fetchFavorites() async {
        do {
            favoriteCities = try await supabase.fetchFavoriteCities()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleFavorite(_ city: City) async {
        let isFavorite = favoriteCities.contains { $0.cityName == city.cityName }
        
        do {
            if isFavorite {
                if let favoriteCity = favoriteCities.first(where: { $0.cityName == city.cityName }) {
                    try await supabase.removeFavoriteCity(favoriteCity.id)
                }
            } else {
                try await supabase.addFavoriteCity(city)
                addToRecentSearches(city)
            }
            await fetchFavorites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func isFavorite(_ city: City) -> Bool {
        favoriteCities.contains { $0.cityName == city.cityName }
    }
    
    func addToRecentSearches(_ city: City) {
        // Remove if already exists
        recentSearches.removeAll { $0.cityName == city.cityName }
        // Add to beginning
        recentSearches.insert(city, at: 0)
        // Keep only last 5
        if recentSearches.count > 5 {
            recentSearches = Array(recentSearches.prefix(5))
        }
        saveRecentSearches()
    }
    
    private func saveRecentSearches() {
        if let encoded = try? JSONEncoder().encode(recentSearches) {
            recentSearchesData = encoded
        }
    }
    
    private func loadRecentSearches() {
        if let decoded = try? JSONDecoder().decode([City].self, from: recentSearchesData) {
            recentSearches = decoded
        }
    }
}

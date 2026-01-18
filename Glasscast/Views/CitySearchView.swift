//
//  CitySearchView.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import SwiftUI


struct CitySearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @StateObject private var weatherViewModel = WeatherViewModel()
    
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
                
                VStack(spacing: 0) {
                    GlassTextField(placeholder: "Search cities...", text: $viewModel.searchQuery)
                        .padding()
                        .onChange(of: viewModel.searchQuery) { 
                            viewModel.search()
                        }
                    
                    if viewModel.isSearching {
                        ProgressView()
                            .tint(.white)
                            .padding()
                    } else if viewModel.searchQuery.isEmpty && !viewModel.recentSearches.isEmpty {
                        // Show recent searches when search is empty
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Recent Searches")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top)
                                
                                ForEach(viewModel.recentSearches) { city in
                                    CityResultRowView(city: city, isFavorite: viewModel.isFavorite(city)) {
                                        Task {
                                            await viewModel.toggleFavorite(city)
                                        }
                                    } onDelete: <#() -> Void#>
                                    .padding(.horizontal)
                                }
                            }
                        }
                    } else if !viewModel.searchResults.isEmpty {
                        List {
                            ForEach(viewModel.searchResults) { city in
                                CityResultRowView(city: city, isFavorite: viewModel.isFavorite(city)) {
                                    Task {
                                        await viewModel.toggleFavorite(city)
                                    }
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    } else if !viewModel.searchQuery.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.5))
                            Text("No cities found")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "location.magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.5))
                            Text("Search for a city")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            .navigationTitle("Search Cities")
        }
    }
}
#Preview {
    CitySearchView()
}

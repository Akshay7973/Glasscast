//
//  ContentView.swift
//  Glasscast
//
//  Created by Akshay Gandal on 17/01/26.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    CitySearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    
                    SettingsView()
                        .environmentObject(authViewModel)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                }
            } else {
                AuthView(viewModel: authViewModel)
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            authViewModel.checkAuthStatus()
        }
    }
}

#Preview {
    ContentView()
}

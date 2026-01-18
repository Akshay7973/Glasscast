//
//  SettingView.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import SwiftUI
import CoreLocation

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignOutAlert = false
    
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
                        // Account Section
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Account")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(viewModel.userEmail)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        
                        // Temperature Unit Section
                        GlassCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Temperature Unit")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    Text("Currently displaying in \(viewModel.currentUnit == .celsius ? "Celsius (°C)" : "Fahrenheit (°F)")")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                Button(action: {
                                    #if os(iOS)
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    #endif
                                    viewModel.toggleUnit()
                                }) {
                                    Text(viewModel.currentUnit.symbol)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(.ultraThinMaterial)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Location Permission Section
                        GlassCard {
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Location Access")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                        HStack(spacing: 5) {
                                            Circle()
                                                .fill(viewModel.locationStatusColor)
                                                .frame(width: 8, height: 8)
                                            Text(viewModel.locationStatusText)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                if viewModel.locationAuthStatus == .notDetermined {
                                    Button(action: {
                                        viewModel.requestLocationPermission()
                                    }) {
                                        Text("Enable Location")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(.blue.opacity(0.3))
                                            .cornerRadius(10)
                                    }
                                } else if viewModel.locationAuthStatus == .denied || viewModel.locationAuthStatus == .restricted {
                                    Button(action: {
                                        viewModel.openAppSettings()
                                    }) {
                                        Text("Open Settings")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(.orange.opacity(0.3))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Sign Out Button
                        Button(action: {
                            showSignOutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.purple.opacity(0.6), .pink.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(15)
                        }
                        .padding()
                        .alert("Sign Out", isPresented: $showSignOutAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Sign Out", role: .destructive) {
                                Task {
                                    await authViewModel.signOut()
                                }
                            }
                        } message: {
                            Text("Are you sure you want to sign out?")
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Settings")
        }
    }
}


//#Preview {
//    SettingView()
//}

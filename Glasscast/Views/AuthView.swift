//
//  AuthView.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isSignUp = false
    
    private var errorBackground: some View {
        #if os(iOS) && swift(>=6.0)
        RoundedRectangle(cornerRadius: 12)
            .fill(.regularMaterial.tint(Color.red.opacity(0.15)))
            .glassEffect(.regular)
        #else
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.red.opacity(0.1))
            .background(.ultraThinMaterial)
        #endif
    }
    
    var body: some View {
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
                LinearGradient(colors: [.blue, .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 20) {
                
                Image(systemName: "cloud.sun.rain.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: .white.opacity(0.3), radius: 10)
                
                Text("Glasscast")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                GlassCard {
                    VStack(spacing: 15) {
                        GlassTextField(placeholder: "Email", text: $viewModel.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        GlassTextField(placeholder: "Password", text: $viewModel.password, isSecure: true)
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption.weight(.medium))  // Medium for legibility
                                .foregroundStyle(.primary)  // System semantic: black/dark on light glass, white/light on dark [web:142]
                                .tint(.red)  // Error accent (iOS 26 system red)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(errorBackground)  // Your computed prop
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.4), lineWidth: 0.5)
                                )// Red tint overlay (works everywhere)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 0.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: Color.red.opacity(0.25), radius: 4)
                                .padding(.horizontal)
                                .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
                        }

                        
                        GlassButton(
                            title: isSignUp ? "Sign Up" : "Sign In",
                            action: {
                                Task {
                                    if isSignUp {
                                        await viewModel.signUp()
                                    } else {
                                        await viewModel.signIn()
                                    }
                                }
                            },
                            isLoading: viewModel.isLoading
                        )
                        
                        Button(action: {
                            isSignUp.toggle()
                            viewModel.errorMessage = nil
                        }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}

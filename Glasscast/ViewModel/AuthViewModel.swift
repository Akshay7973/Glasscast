//
//  AuthViewModel.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let supabase = SupabaseService.shared
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isAuthenticated = supabase.getCurrentUser() != nil
    }
    
    func signIn() async {
        // Validate input
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await supabase.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
            isAuthenticated = true
            clearFields()
        } catch let error as SupabaseError {
            handleSupabaseError(error)
        } catch {
            errorMessage = "Sign in failed. Please check your credentials and try again."
        }
        
        isLoading = false
    }
    
    func signUp() async {
        // Validate input
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter a password"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await supabase.signUp(email: email.trimmingCharacters(in: .whitespaces), password: password)
            isAuthenticated = true
            clearFields()
        } catch let error as SupabaseError {
            handleSupabaseError(error)
        } catch {
            errorMessage = "Sign up failed. Please try again or use a different email."
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.signOut()
            isAuthenticated = false
            clearFields()
        } catch let error as SupabaseError {
            handleSupabaseError(error)
        } catch {
            errorMessage = "Failed to sign out. Please try again."
        }
        
        isLoading = false
    }
    
    private func handleSupabaseError(_ error: SupabaseError) {
        switch error {
        case .notAuthenticated:
            errorMessage = "Authentication required. Please sign in."
        case .userNotFound:
            errorMessage = "No account found with this email."
        case .invalidCredentials:
            errorMessage = "Invalid email or password. Please check your credentials."
        case .userAlreadyExists:
            errorMessage = "This email is already registered. Please sign in instead."
        case .weakPassword:
            errorMessage = "Password is too weak. Use at least 6 characters with letters and numbers."
        case .invalidEmail:
            errorMessage = "Please enter a valid email address."
        case .databaseError(let message):
            errorMessage = "Database error: \(message)"
        case .networkError:
            errorMessage = "No internet connection. Please check your network and try again."
        case .decodingError:
            errorMessage = "Something went wrong processing the response. Please try again."
        case .unknown(let message):
            errorMessage = message
        }
    }
    
    private func clearFields() {
        email = ""
        password = ""
        errorMessage = nil
    }
}





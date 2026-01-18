import Foundation
import Supabase
import Auth

enum SupabaseError: Error, LocalizedError {
    case notAuthenticated
    case userNotFound
    case invalidCredentials  // Added this
    case userAlreadyExists
    case weakPassword
    case invalidEmail
    case databaseError(String)
    case networkError
    case decodingError
    case unknown(String?)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Authentication required."
        case .userNotFound: return "User not found."
        case .invalidCredentials: return "Invalid email or password."  // Matches Supabase "Invalid login credentials"
        case .userAlreadyExists: return "User already exists."
        case .weakPassword: return "Password too weak."
        case .invalidEmail: return "Invalid email."
        case .databaseError(let msg): return "Database error: \(msg)"
        case .networkError: return "Network error."
        case .decodingError: return "Decoding error."
        case .unknown(let msg): return msg ?? "Unknown error."
        }
    }
}


final class SupabaseService {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    
    

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: AppConstants.supabaseURL)!,
            supabaseKey: AppConstants.supabaseAnonKey
        )
        
        // Suppress the session warning by configuring auth
        Task {
            _ = try? await client.auth.session
        }
    }

    
    // MARK: - Authentication
    
    @MainActor
    func signUp(email: String, password: String) async throws -> User {
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            let user = response.user
            
            return User(
                id: user.id,
                email: user.email ?? email,
                createdAt: user.createdAt
            )
        } catch {
            let supabaseError = mapAuthError(error)
            print("❌ Signin error: \(error) → \(supabaseError.errorDescription ?? "unknown")")
            throw supabaseError
        }
    }
    
    @MainActor
    func signIn(email: String, password: String) async throws -> User {
        do {
            let response = try await client.auth.signIn(
                email: email,
                password: password
            )
            
            let user = response.user
            
            return User(
                id: user.id,
                email: user.email ?? email,
                createdAt: user.createdAt
            )
        } catch {
            let supabaseError = mapAuthError(error)
            print("❌ Signin error: \(error) → \(supabaseError.errorDescription ?? "unknown")")
            throw supabaseError
        }
    }
    
    @MainActor
    func signOut() async throws {
        do {
            try await client.auth.signOut()
        } catch {
            throw mapAuthError(error)
        }
    }
    
    // Smart error mapper - replaces blind networkError
    private func mapAuthError(_ error: Error) -> SupabaseError {
        if let _ = error as? URLError {
            return .networkError  // True network (timeout, no connection)
        }
        let message = error.localizedDescription.lowercased()
        if message.contains("invalid login credentials") || message.contains("invalid credentials") {
            return .invalidCredentials
        }
        if message.contains("user not found") {
            return .userNotFound
        }
        if message.contains("already exists") || message.contains("already registered") {
            return .userAlreadyExists
        }
        if message.contains("weak password") || message.contains("password policy") {
            return .weakPassword
        }
        if message.contains("invalid email") {
            return .invalidEmail
        }
        return .unknown(message)
    }
    
    func getCurrentUser() -> User? {
        guard let session = client.auth.currentSession else {
            return nil
        }
        
        let user = session.user
        
        return User(
            id: user.id,
            email: user.email ?? "",
            createdAt: user.createdAt
        )
    }
    
    // MARK: - Favorite Cities
    
    func fetchFavoriteCities() async throws -> [City] {
        guard let userId = getCurrentUser()?.id else {
            throw SupabaseError.notAuthenticated
        }
        
        do {
            let response: [City] = try await client
                .from("favorite_cities")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            return response
        } catch {
            print("Fetch favorites error: \(error)")
            throw SupabaseError.databaseError(error.localizedDescription)
        }
    }
    
    func addFavoriteCity(_ city: City) async throws {
        guard let userId = getCurrentUser()?.id else {
            throw SupabaseError.notAuthenticated
        }
        
        struct FavoriteCity: Encodable {
            let user_id: String
            let city_name: String
            let country_code: String
            let lat: Double
            let lon: Double
        }
        
        let favoriteCity = FavoriteCity(
            user_id: userId.uuidString,
            city_name: city.cityName,
            country_code: city.countryCode ?? "",
            lat: city.lat,
            lon: city.lon
        )
        
        do {
            try await client
                .from("favorite_cities")
                .insert(favoriteCity)
                .execute()
        } catch {
            print("Add favorite error: \(error)")
            throw SupabaseError.databaseError(error.localizedDescription)
        }
    }
    
    func removeFavoriteCity(_ cityId: UUID) async throws {
        guard getCurrentUser() != nil else {
            throw SupabaseError.notAuthenticated
        }
        
        do {
            try await client
                .from("favorite_cities")
                .delete()
                .eq("id", value: cityId.uuidString)
                .execute()
        } catch {
            print("Remove favorite error: \(error)")
            throw SupabaseError.databaseError(error.localizedDescription)
        }
    }
    
    func isCityFavorite(cityName: String) async throws -> Bool {
        guard let userId = getCurrentUser()?.id else {
            return false
        }
        
        do {
            let response: [City] = try await client
                .from("favorite_cities")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("city_name", value: cityName)
                .execute()
                .value
            
            return !response.isEmpty
        } catch {
            return false
        }
    }
}

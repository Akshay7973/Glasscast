//
//  User.swift
//  Glasscast
//
//  Created by Akshay Gandal on 18/01/26.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case createdAt = "created_at"
    }
}


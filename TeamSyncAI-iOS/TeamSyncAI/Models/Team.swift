import Foundation

// MARK: - Team Models

struct Team: Codable, Identifiable {
    let id: String
    let name: String
    let sport: String
    let ageGroup: String
    let coachId: String
    let description: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, sport
        case ageGroup = "age_group"
        case coachId = "coach_id"
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Player: Codable, Identifiable {
    let id: String
    let teamId: String
    let name: String
    let age: Int
    let position: String
    let jerseyNumber: Int
    let email: String?
    let phone: String?
    let emergencyContact: String?
    let medicalNotes: String?
    let photoURL: URL?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case name, age, position
        case jerseyNumber = "jersey_number"
        case email, phone
        case emergencyContact = "emergency_contact"
        case medicalNotes = "medical_notes"
        case photoURL = "photo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Coach: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let specialization: String?
    let certifications: [String]
    let bio: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, specialization, certifications, bio
        case createdAt = "created_at"
    }
}

struct Staff: Codable, Identifiable {
    let id: String
    let teamId: String
    let name: String
    let role: String
    let email: String?
    let phone: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case name, role, email, phone
        case createdAt = "created_at"
    }
}

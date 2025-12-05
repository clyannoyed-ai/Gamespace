import Foundation

// MARK: - Drill Models

struct Drill: Codable, Identifiable {
    let id: String
    let ageGroup: String
    let name: String
    let type: DrillType
    let description: String
    let keyPoints: [String]
    let formation: String
    let tactics: String
    let duration: Int? // minutes
    let difficulty: DifficultyLevel
    let equipment: [String]
    let visual: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case ageGroup = "ageGroup"
        case name, type, description
        case keyPoints = "keyPoints"
        case formation, tactics, duration, difficulty, equipment, visual
    }
}

enum DrillType: String, Codable {
    case attacking = "attacking"
    case defensive = "defensive"
    case positioning = "positioning"
    case shooting = "shooting"
    case passing = "passing"
    case dribbling = "dribbling"
    case conditioning = "conditioning"
}

enum DifficultyLevel: String, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

struct Practice: Codable, Identifiable {
    let id: String
    let eventId: String
    let teamId: String
    let title: String
    let date: Date
    let duration: Int // minutes
    let focus: String
    let drills: [String] // drill IDs
    let notes: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case teamId = "team_id"
        case title, date, duration, focus, drills, notes
        case createdAt = "created_at"
    }
}

struct FieldFormation: Codable, Identifiable {
    let id: String
    let name: String
    let formation: String // e.g., "4-4-2"
    let description: String?
    let positions: [FieldPosition]
    let ageGroup: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, formation, description, positions
        case ageGroup = "age_group"
    }
}

struct FieldPosition: Codable {
    let positionName: String
    let x: Double
    let y: Double
    let role: String
    let responsibilities: [String]
    
    enum CodingKeys: String, CodingKey {
        case positionName = "positionName"
        case x, y, role, responsibilities
    }
}

struct PlayStrategy: Codable, Identifiable {
    let id: String
    let ageGroup: String
    let name: String
    let type: StrategyType
    let description: String
    let keyPoints: [String]
    let formation: String
    let tactics: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case ageGroup = "ageGroup"
        case name, type, description
        case keyPoints = "keyPoints"
        case formation, tactics
    }
}

enum StrategyType: String, Codable {
    case attacking = "attacking"
    case defensive = "defensive"
    case transition = "transition"
    case setPlay = "set_play"
}

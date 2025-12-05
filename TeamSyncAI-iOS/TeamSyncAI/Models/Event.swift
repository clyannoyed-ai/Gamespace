import Foundation

// MARK: - Event Models

struct Event: Codable, Identifiable {
    let id: String
    let teamId: String
    let title: String
    let eventType: EventType
    let startTime: Date
    let endTime: Date
    let location: String?
    let latitude: Double?
    let longitude: Double?
    let description: String?
    let recurrence: RecurrencePattern?
    let equipmentNeeded: [String]
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case title
        case eventType = "event_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case location, latitude, longitude, description, recurrence
        case equipmentNeeded = "equipment_needed"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum EventType: String, Codable {
    case practice = "Practice"
    case game = "Game"
    case meeting = "Meeting"
    case social = "Social"
    case training = "Training"
}

struct RecurrencePattern: Codable {
    let frequency: RecurrenceFrequency
    let interval: Int
    let endDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case frequency, interval
        case endDate = "end_date"
    }
}

enum RecurrenceFrequency: String, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case biweekly = "biweekly"
    case monthly = "monthly"
}

struct EventAttendance: Codable, Identifiable {
    let id: String
    let eventId: String
    let playerId: String
    let status: AttendanceStatus
    let notes: String?
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case playerId = "player_id"
        case status, notes
        case updatedAt = "updated_at"
    }
}

enum AttendanceStatus: String, Codable {
    case attending = "Attending"
    case notAttending = "Not Attending"
    case maybe = "Maybe"
    case pending = "Pending"
}

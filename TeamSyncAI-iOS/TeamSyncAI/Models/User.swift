import Foundation

// MARK: - User & Auth Models

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let role: UserRole
    let profilePhoto: URL?
    let phone: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, role
        case profilePhoto = "profile_photo"
        case phone
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum UserRole: String, Codable {
    case coach = "coach"
    case parent = "parent"
    case player = "player"
    case admin = "admin"
    case staff = "staff"
}

struct NotificationPreference: Codable, Identifiable {
    let id: String
    let userId: String
    let pushNotifications: Bool
    let emailNotifications: Bool
    let messageNotifications: Bool
    let announcementNotifications: Bool
    let eventReminders: Bool
    let reminderTime: Int // minutes before event
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case pushNotifications = "push_notifications"
        case emailNotifications = "email_notifications"
        case messageNotifications = "message_notifications"
        case announcementNotifications = "announcement_notifications"
        case eventReminders = "event_reminders"
        case reminderTime = "reminder_time"
    }
}

struct AuthResponse: Codable {
    let user: User
    let token: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case user, token
        case refreshToken = "refresh_token"
    }
}

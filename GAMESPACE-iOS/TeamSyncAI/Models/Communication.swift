import Foundation

// MARK: - Communication Models

struct Message: Codable, Identifiable {
    let id: String
    let senderId: String
    let senderName: String
    let teamId: String
    let content: String
    let messageType: MessageType
    let attachments: [Attachment]?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId = "sender_id"
        case senderName = "sender_name"
        case teamId = "team_id"
        case content
        case messageType = "message_type"
        case attachments
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum MessageType: String, Codable {
    case text = "text"
    case image = "image"
    case video = "video"
    case voice = "voice"
}

struct Attachment: Codable, Identifiable {
    let id: String
    let messageId: String
    let url: URL
    let type: String
    let size: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case messageId = "message_id"
        case url, type, size
    }
}

struct Announcement: Codable, Identifiable {
    let id: String
    let teamId: String
    let title: String
    let content: String
    let authorId: String
    let authorName: String
    let priority: AnnouncementPriority
    let createdAt: Date
    let expiresAt: Date?
    let read: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case title, content
        case authorId = "author_id"
        case authorName = "author_name"
        case priority
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case read
    }
}

enum AnnouncementPriority: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
}

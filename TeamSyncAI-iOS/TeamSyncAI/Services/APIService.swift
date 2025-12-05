import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL: URL
    private var authToken: String?
    
    private init() {
        // Replace with your actual Supabase/backend URL
        self.baseURL = URL(string: "https://your-backend-url.com/api/v1")!
    }
    
    /// Set authentication token
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    /// Generic request method
    private func request<T: Decodable>(
        method: String,
        endpoint: String,
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Team Endpoints
    
    func fetchTeams() async throws -> [Team] {
        try await request(method: "GET", endpoint: "teams")
    }
    
    func fetchTeam(id: String) async throws -> Team {
        try await request(method: "GET", endpoint: "teams/\(id)")
    }
    
    // MARK: - Player Endpoints
    
    func fetchPlayers(teamId: String) async throws -> [Player] {
        try await request(method: "GET", endpoint: "teams/\(teamId)/players")
    }
    
    func addPlayer(_ player: Player, teamId: String) async throws -> Player {
        try await request(method: "POST", endpoint: "teams/\(teamId)/players", body: player)
    }
    
    func updatePlayer(_ player: Player, teamId: String) async throws -> Player {
        try await request(method: "PUT", endpoint: "teams/\(teamId)/players/\(player.id)", body: player)
    }
    
    func deletePlayer(id: String, teamId: String) async throws {
        _ = try await request(method: "DELETE", endpoint: "teams/\(teamId)/players/\(id)") as EmptyResponse
    }
    
    // MARK: - Event Endpoints
    
    func fetchEvents(teamId: String) async throws -> [Event] {
        try await request(method: "GET", endpoint: "teams/\(teamId)/events")
    }
    
    func fetchEvent(id: String, teamId: String) async throws -> Event {
        try await request(method: "GET", endpoint: "teams/\(teamId)/events/\(id)")
    }
    
    func createEvent(_ event: Event, teamId: String) async throws -> Event {
        try await request(method: "POST", endpoint: "teams/\(teamId)/events", body: event)
    }
    
    func updateEvent(_ event: Event, teamId: String) async throws -> Event {
        try await request(method: "PUT", endpoint: "teams/\(teamId)/events/\(event.id)", body: event)
    }
    
    func deleteEvent(id: String, teamId: String) async throws {
        _ = try await request(method: "DELETE", endpoint: "teams/\(teamId)/events/\(id)") as EmptyResponse
    }
    
    // MARK: - Attendance Endpoints
    
    func fetchAttendance(eventId: String, teamId: String) async throws -> [EventAttendance] {
        try await request(method: "GET", endpoint: "teams/\(teamId)/events/\(eventId)/attendance")
    }
    
    func updateAttendance(_ attendance: EventAttendance, eventId: String, teamId: String) async throws -> EventAttendance {
        try await request(method: "PUT", endpoint: "teams/\(teamId)/events/\(eventId)/attendance/\(attendance.playerId)", body: attendance)
    }
    
    // MARK: - Message Endpoints
    
    func fetchMessages(teamId: String) async throws -> [Message] {
        try await request(method: "GET", endpoint: "teams/\(teamId)/messages")
    }
    
    func sendMessage(_ message: Message, teamId: String) async throws -> Message {
        try await request(method: "POST", endpoint: "teams/\(teamId)/messages", body: message)
    }
    
    // MARK: - Announcement Endpoints
    
    func fetchAnnouncements(teamId: String) async throws -> [Announcement] {
        try await request(method: "GET", endpoint: "teams/\(teamId)/announcements")
    }
    
    func markAnnouncementAsRead(announcementId: String, teamId: String) async throws {
        _ = try await request(method: "PUT", endpoint: "teams/\(teamId)/announcements/\(announcementId)/read") as EmptyResponse
    }
    
    // MARK: - Drill Endpoints
    
    func fetchDrills(ageGroup: String) async throws -> [Drill] {
        try await request(method: "GET", endpoint: "drills?ageGroup=\(ageGroup)")
    }
    
    func fetchPlayStrategies(ageGroup: String) async throws -> [PlayStrategy] {
        try await request(method: "GET", endpoint: "strategies?ageGroup=\(ageGroup)")
    }
    
    // MARK: - AI Chat Endpoints
    
    func sendChatMessage(message: String, context: [String: Any]) async throws -> String {
        struct ChatRequest: Encodable {
            let message: String
            let context: [String: AnyCodable]
        }
        
        struct ChatResponse: Decodable {
            let response: String
        }
        
        let contextData = context.mapValues { AnyCodable($0) }
        let request = ChatRequest(message: message, context: contextData)
        let response: ChatResponse = try await self.request(method: "POST", endpoint: "chat", body: request)
        return response.response
    }
}

// MARK: - Helper Types

struct EmptyResponse: Decodable {}

enum APIError: Error {
    case invalidResponse
    case serverError(Int)
    case decodingError(Error)
    case networkError(Error)
}

// Helper for encoding Any values
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intVal as Int:
            try container.encode(intVal)
        case let doubleVal as Double:
            try container.encode(doubleVal)
        case let stringVal as String:
            try container.encode(stringVal)
        case let boolVal as Bool:
            try container.encode(boolVal)
        default:
            try container.encodeNil()
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else {
            value = NSNull()
        }
    }
}

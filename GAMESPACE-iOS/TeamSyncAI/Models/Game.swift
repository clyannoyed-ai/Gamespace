import Foundation

struct Game: Codable, Identifiable {
    let id: String
    let opponent: String
    let date: Date
    let location: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, opponent, date, location, status
    }
}

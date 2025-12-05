import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName
        case role
    }
}

import Foundation

struct Team: Codable, Identifiable {
    let id: String
    let name: String
    let sport: String
    let memberCount: Int
    let members: [TeamMember]
    
    static let example = Team(
        id: "1",
        name: "Dragons",
        sport: "Soccer",
        memberCount: 11,
        members: [
            TeamMember(id: "1", name: "John Doe", role: "Coach", initials: "JD"),
            TeamMember(id: "2", name: "Jane Smith", role: "Player", initials: "JS")
        ]
    )
}

struct TeamMember: Codable, Identifiable {
    let id: String
    let name: String
    let role: String
    let initials: String
}

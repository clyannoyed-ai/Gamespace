import Foundation
import Combine

class TeamViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var games: [Game] = []
    @Published var isLoading = false
    
    private let networkManager = NetworkManager()
    
    func fetchTeams() {
        isLoading = true
        networkManager.get(endpoint: "/teams") { (result: Result<[Team], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let teams):
                    self.teams = teams
                case .failure(let error):
                    print("Error fetching teams: \(error)")
                }
                self.isLoading = false
            }
        }
    }
    
    func createTeam(name: String, sport: String) {
        let teamData = ["name": name, "sport": sport]
        networkManager.post(endpoint: "/teams", body: teamData) { (result: Result<Team, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let team):
                    self.teams.append(team)
                case .failure(let error):
                    print("Error creating team: \(error)")
                }
            }
        }
    }
    
    func fetchGames() {
        networkManager.get(endpoint: "/games") { (result: Result<[Game], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    self.games = games
                case .failure(let error):
                    print("Error fetching games: \(error)")
                }
            }
        }
    }
}

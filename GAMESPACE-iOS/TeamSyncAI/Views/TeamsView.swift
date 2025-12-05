import SwiftUI

struct TeamsView: View {
    @EnvironmentObject var teamVM: TeamViewModel
    @State private var showCreateTeam = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if teamVM.teams.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.3")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No Teams")
                            .font(.headline)
                        Text("Create or join a team to get started")
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    List(teamVM.teams) { team in
                        NavigationLink(destination: TeamDetailView(team: team)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(team.name)
                                    .font(.headline)
                                Text("\(team.memberCount) members")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Teams")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showCreateTeam = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateTeam) {
                CreateTeamView()
                    .environmentObject(teamVM)
            }
            .onAppear {
                teamVM.fetchTeams()
            }
        }
    }
}

#Preview {
    TeamsView()
        .environmentObject(TeamViewModel())
}

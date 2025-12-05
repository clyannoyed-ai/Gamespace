import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var teamVM: TeamViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if teamVM.games.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No Games Scheduled")
                            .font(.headline)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    List(teamVM.games) { game in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(game.opponent)
                                .font(.headline)
                            HStack {
                                Text(game.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                Spacer()
                                Text(game.location)
                                    .font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Schedule")
            .onAppear {
                teamVM.fetchGames()
            }
        }
    }
}

#Preview {
    ScheduleView()
        .environmentObject(TeamViewModel())
}

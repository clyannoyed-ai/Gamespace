import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var teamVM: TeamViewModel
    
    var body: some View {
        TabView {
            TeamsView()
                .tabItem {
                    Label("Teams", systemImage: "person.3")
                }
            
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(TeamViewModel())
}

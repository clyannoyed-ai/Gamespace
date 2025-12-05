import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            // Roster Tab
            RosterView()
                .tabItem {
                    Label("Roster", systemImage: "person.3.fill")
                }
                .tag(1)
            
            // Scheduling Tab
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(2)
            
            // Drills Tab
            DrillsView()
                .tabItem {
                    Label("Drills", systemImage: "figure.soccer")
                }
                .tag(3)
            
            // Messages Tab
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "bubble.left.fill")
                }
                .tag(4)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(5)
        }
        .onAppear {
            requestNotificationPermissions()
        }
    }
    
    private func requestNotificationPermissions() {
        Task {
            _ = await NotificationService.shared.requestAuthorizationIfNeeded()
        }
    }
}

struct DashboardView: View {
    @State private var upcomingEvents: [Event] = []
    @State private var isLoading = true
    @State private var selectedTeam: Team?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dashboard")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Welcome back!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                if isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Upcoming Events Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Upcoming Events")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                if upcomingEvents.isEmpty {
                                    Text("No upcoming events")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 24)
                                } else {
                                    ForEach(upcomingEvents.prefix(3)) { event in
                                        EventCard(event: event)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Quick Actions
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Quick Actions")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                HStack(spacing: 12) {
                                    QuickActionButton(title: "New Event", icon: "plus.circle", color: .blue)
                                    QuickActionButton(title: "Message Team", icon: "bubble.left", color: .green)
                                    QuickActionButton(title: "View Drills", icon: "figure.soccer", color: .orange)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadDashboard()
        }
    }
    
    private func loadDashboard() {
        isLoading = true
        Task {
            // Fetch upcoming events
            // upcomingEvents = try await APIService.shared.fetchEvents(teamId: selectedTeam?.id ?? "")
            isLoading = false
        }
    }
}

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.eventType.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(event.startTime, style: .time)
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(event.startTime, style: .date)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            if let location = event.location {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .foregroundColor(color)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}

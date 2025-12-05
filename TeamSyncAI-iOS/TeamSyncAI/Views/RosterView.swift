import SwiftUI

struct RosterView: View {
    @State private var players: [Player] = []
    @State private var isLoading = true
    @State private var showAddPlayer = false
    @State private var searchText = ""
    
    var filteredPlayers: [Player] {
        if searchText.isEmpty {
            return players
        }
        return players.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                    .padding()
                
                if isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                } else if filteredPlayers.isEmpty {
                    EmptyStateView(
                        title: "No Players",
                        description: "Add your first player to get started",
                        action: { showAddPlayer = true }
                    )
                } else {
                    List(filteredPlayers) { player in
                        NavigationLink(destination: PlayerDetailView(player: player)) {
                            PlayerRowView(player: player)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Roster")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddPlayer = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddPlayer) {
                AddPlayerView(isPresented: $showAddPlayer, onAdd: { player in
                    players.append(player)
                })
            }
        }
        .onAppear {
            loadPlayers()
        }
    }
    
    private func loadPlayers() {
        isLoading = true
        Task {
            // Load from API
            // players = try await APIService.shared.fetchPlayers(teamId: teamId)
            isLoading = false
        }
    }
}

struct PlayerRowView: View {
    let player: Player
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let photoURL = player.photoURL {
                AsyncImage(url: photoURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 44, height: 44)
                .background(Color(.systemGray3))
                .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray3))
                    .clipShape(Circle())
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                HStack(spacing: 12) {
                    Label(String(player.jerseyNumber), systemImage: "number")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Label(player.position, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct PlayerDetailView: View {
    let player: Player
    @Environment(\\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with photo
                if let photoURL = player.photoURL {
                    AsyncImage(url: photoURL) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Color.gray
                        }
                    }
                    .frame(height: 300)
                    .clipped()
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .background(Color(.systemGray3))
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Basic Info
                    Text(player.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Section(header: Text("Player Information")) {
                        InfoRow(label: "Jersey Number", value: String(player.jerseyNumber))
                        InfoRow(label: "Position", value: player.position)
                        InfoRow(label: "Age", value: String(player.age))
                    }
                    
                    if let email = player.email {
                        Section(header: Text("Contact")) {
                            InfoRow(label: "Email", value: email)
                        }
                    }
                    
                    if let phone = player.phone {
                        InfoRow(label: "Phone", value: phone)
                    }
                    
                    if let emergency = player.emergencyContact {
                        Section(header: Text("Emergency")) {
                            InfoRow(label: "Contact", value: emergency)
                        }
                    }
                    
                    if let medical = player.medicalNotes {
                        Section(header: Text("Medical Notes")) {
                            Text(medical)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Player Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

struct AddPlayerView: View {
    @Binding var isPresented: Bool
    var onAdd: (Player) -> Void
    
    @State private var name = ""
    @State private var jerseyNumber = ""
    @State private var position = ""
    @State private var age = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Player Information") {
                    TextField("Name", text: $name)
                    TextField("Jersey Number", text: $jerseyNumber)
                        .keyboardType(.numberPad)
                    TextField("Position", text: $position)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button("Add Player") {
                        addPlayer()
                    }
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func addPlayer() {
        // Create and add player
        isPresented = false
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search players", text: $text)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct EmptyStateView: View {
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: action) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(24)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    RosterView()
}

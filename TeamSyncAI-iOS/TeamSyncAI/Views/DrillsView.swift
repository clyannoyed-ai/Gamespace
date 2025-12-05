import SwiftUI

struct DrillsView: View {
    @State private var drills: [Drill] = []
    @State private var strategies: [PlayStrategy] = []
    @State private var isLoading = true
    @State private var selectedTab = 0
    @State private var selectedAgeGroup = "U6"
    
    let ageGroups = ["U6", "U8", "U10", "U12", "U14", "U16", "U18"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Age Group Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ageGroups, id: \\.self) { age in
                            Button(action: { selectedAgeGroup = age; loadDrills() }) {
                                Text(age)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedAgeGroup == age ? Color.blue : Color(.systemGray6))
                                    .foregroundColor(selectedAgeGroup == age ? .white : .primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray6))
                
                // Tab Selection
                Picker("Content", selection: $selectedTab) {
                    Text("Drills").tag(0)
                    Text("Strategies").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                } else if selectedTab == 0 {
                    DrillsListView(drills: drills)
                } else {
                    StrategiesListView(strategies: strategies)
                }
            }
            .navigationTitle("Drills & Strategies")
        }
        .onAppear {
            loadDrills()
        }
    }
    
    private func loadDrills() {
        isLoading = true
        Task {
            do {
                drills = try await APIService.shared.fetchDrills(ageGroup: selectedAgeGroup)
                strategies = try await APIService.shared.fetchPlayStrategies(ageGroup: selectedAgeGroup)
                isLoading = false
            } catch {
                print("Error loading drills: \(error)")
                isLoading = false
            }
        }
    }
}

struct DrillsListView: View {
    let drills: [Drill]
    
    var body: some View {
        if drills.isEmpty {
            EmptyStateView(
                title: "No Drills Available",
                description: "Check back later for more drills",
                action: {}
            )
        } else {
            List(drills) { drill in
                NavigationLink(destination: DrillDetailView(drill: drill)) {
                    DrillRowView(drill: drill)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct DrillRowView: View {
    let drill: Drill
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(drill.name)
                        .font(.headline)
                    Text(drill.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Label(drill.difficulty.rawValue, systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Text(drill.description)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

struct DrillDetailView: View {
    let drill: Drill
    @State private var isFavorite = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(drill.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 12) {
                        Label(drill.type.rawValue, systemImage: "flag.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Label(drill.difficulty.rawValue, systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                    Text(drill.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                
                // Key Points
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Points")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(drill.keyPoints, id: \\.self) { point in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text(point)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding()
                
                // Formation & Tactics
                VStack(alignment: .leading, spacing: 12) {
                    Section(header: Text("Formation")) {
                        Text(drill.formation)
                            .font(.caption)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                    }
                    
                    Section(header: Text("Tactics")) {
                        Text(drill.tactics)
                            .font(.caption)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                    }
                    
                    if !drill.equipment.isEmpty {
                        Section(header: Text("Equipment")) {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(drill.equipment, id: \\.self) { item in
                                    Label(item, systemImage: "cube.fill")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .padding()
                
                Button(action: { isFavorite.toggle() }) {
                    Label(isFavorite ? "Saved" : "Save Drill", systemImage: isFavorite ? "heart.fill" : "heart")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(isFavorite ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .navigationTitle("Drill Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StrategiesListView: View {
    let strategies: [PlayStrategy]
    
    var body: some View {
        if strategies.isEmpty {
            EmptyStateView(
                title: "No Strategies",
                description: "Strategies will be available soon",
                action: {}
            )
        } else {
            List(strategies) { strategy in
                NavigationLink(destination: StrategyDetailView(strategy: strategy)) {
                    StrategyRowView(strategy: strategy)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct StrategyRowView: View {
    let strategy: PlayStrategy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(strategy.name)
                        .font(.headline)
                    Text(strategy.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            
            Text(strategy.description)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

struct StrategyDetailView: View {
    let strategy: PlayStrategy
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(strategy.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(strategy.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(strategy.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Points")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(strategy.keyPoints, id: \\.self) { point in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(point)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    Section(header: Text("Formation")) {
                        Text(strategy.formation)
                            .font(.caption)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                    }
                    
                    Section(header: Text("Tactics")) {
                        Text(strategy.tactics)
                            .font(.caption)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Strategy Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DrillsView()
}

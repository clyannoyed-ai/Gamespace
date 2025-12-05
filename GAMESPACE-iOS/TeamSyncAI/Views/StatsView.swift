import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Team Statistics")
                        .font(.headline)
                    
                    HStack {
                        StatBox(title: "Wins", value: "12", color: .green)
                        StatBox(title: "Losses", value: "3", color: .red)
                        StatBox(title: "Draws", value: "1", color: .orange)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Text("Player Stats")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                List {
                    ForEach(0..<5, id: \.self) { _ in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading) {
                                Text("Player Name")
                                    .font(.headline)
                                Text("5 Goals")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Statistics")
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    StatsView()
}

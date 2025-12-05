import SwiftUI

struct TeamDetailView: View {
    @EnvironmentObject var teamVM: TeamViewModel
    let team: Team
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(team.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(team.sport)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Members")
                    .font(.headline)
                
                ForEach(team.members) { member in
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 40, height: 40)
                            .overlay(Text(member.initials).foregroundColor(.white))
                        
                        VStack(alignment: .leading) {
                            Text(member.name)
                            Text(member.role)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Team Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TeamDetailView(team: Team.example)
        .environmentObject(TeamViewModel())
}

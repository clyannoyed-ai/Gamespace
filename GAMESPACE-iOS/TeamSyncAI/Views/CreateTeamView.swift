import SwiftUI

struct CreateTeamView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var teamVM: TeamViewModel
    @State private var teamName = ""
    @State private var sport = "Soccer"
    let sports = ["Soccer", "Basketball", "Football", "Baseball", "Volleyball"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    TextField("Team Name", text: $teamName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Picker("Sport", selection: $sport) {
                        ForEach(sports, id: \.self) { sport in
                            Text(sport).tag(sport)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    teamVM.createTeam(name: teamName, sport: sport)
                    dismiss()
                }) {
                    Text("Create Team")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CreateTeamView()
        .environmentObject(TeamViewModel())
}

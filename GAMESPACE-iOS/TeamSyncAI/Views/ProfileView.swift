import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 80, height: 80)
                        .overlay(Text("JD").font(.title).foregroundColor(.white))
                    
                    Text(authVM.userEmail)
                        .font(.headline)
                    Text("Team Manager")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                VStack(spacing: 12) {
                    NavigationLink(destination: EditProfileView()) {
                        HStack {
                            Text("Edit Profile")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Text("Settings")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                    }
                }
                
                Button(action: { authVM.logout() }) {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Edit Profile")
                .font(.headline)
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.headline)
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}

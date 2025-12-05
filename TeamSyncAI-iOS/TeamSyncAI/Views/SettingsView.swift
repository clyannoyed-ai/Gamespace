import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var notificationsEnabled = true
    @State private var eventReminders = true
    @State private var messageNotifications = true
    @State private var reminderMinutes = 60
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Account Section
                Section("Account") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authManager.currentUser?.name ?? "User")
                                .font(.headline)
                            Text(authManager.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    NavigationLink(destination: EditProfileView()) {
                        Text("Edit Profile")
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        Toggle("Event Reminders", isOn: $eventReminders)
                        Toggle("Message Notifications", isOn: $messageNotifications)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Remind me")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Picker("Minutes before", selection: $reminderMinutes) {
                                Text("15 minutes").tag(15)
                                Text("30 minutes").tag(30)
                                Text("1 hour").tag(60)
                                Text("2 hours").tag(120)
                            }
                        }
                    }
                }
                
                // App Section
                Section("App") {
                    NavigationLink(destination: AboutView()) {
                        Text("About TeamSync AI")
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
                
                // Actions Section
                Section {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        Text("Log Out")
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var bio = ""
    @State private var isLoading = false
    
    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("Full Name", text: $name)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                TextField("Phone", text: $phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            }
            
            Section("About") {
                TextEditor(text: $bio)
                    .frame(height: 100)
            }
            
            Section {
                Button(action: saveProfile) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Save Changes")
                    }
                }
                .disabled(isLoading)
            }
        }
        .navigationTitle("Edit Profile")
        .onAppear {
            name = authManager.currentUser?.name ?? ""
            email = authManager.currentUser?.email ?? ""
            phone = authManager.currentUser?.phone ?? ""
        }
    }
    
    private func saveProfile() {
        isLoading = true
        // Save profile changes
        isLoading = false
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: "figure.soccer")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    Text("TeamSync AI")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "Comprehensive team management platform")
                        BulletPoint(text: "AI-powered drill generation and strategy planning")
                        BulletPoint(text: "Real-time team communication")
                        BulletPoint(text: "Event scheduling and attendance tracking")
                        BulletPoint(text: "Voice-enabled AI coach assistant")
                    }
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Features")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(title: "Team Roster", description: "Manage player profiles and information")
                        FeatureRow(title: "Event Scheduling", description: "Create and track practices and games")
                        FeatureRow(title: "Practice Drills", description: "Access AI-generated drills by age group")
                        FeatureRow(title: "Team Chat", description: "Communicate with coaches and team members")
                        FeatureRow(title: "Announcements", description: "Important team updates and news")
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .navigationTitle("About TeamSync AI")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
            Text(text)
                .font(.caption)
        }
    }
}

struct FeatureRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
            Text(description)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager.shared)
}

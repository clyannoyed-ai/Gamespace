import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("TeamSync AI")
                        .font(.system(size: 32, weight: .bold))
                    Text("Soccer Team Management")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 24)
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.caption)
                        .fontWeight(.semibold)
                    TextField("Enter your email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.caption)
                        .fontWeight(.semibold)
                    SecureField("Enter your password", text: $password)
                        .textContentType(.password)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Login Button
                Button(action: handleLogin) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                // Footer
                VStack(spacing: 12) {
                    Text("Don't have an account?")
                        .font(.caption)
                    NavigationLink("Sign Up", destination: SignupView())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                
                Spacer()
            }
            .padding(24)
            .navigationBarHidden(true)
        }
    }
    
    private func handleLogin() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authManager.login(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct SignupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
    @State private var role = UserRole.parent
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section("Personal Information") {
                TextField("Full Name", text: $name)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
            }
            
            Section("Account") {
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                SecureField("Confirm Password", text: $passwordConfirm)
                    .textContentType(.newPassword)
            }
            
            Section("Role") {
                Picker("I am a", selection: $role) {
                    Text("Coach").tag(UserRole.coach)
                    Text("Parent").tag(UserRole.parent)
                    Text("Player").tag(UserRole.player)
                }
            }
            
            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            
            Section {
                Button(action: handleSignup) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Create Account")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(isLoading || !isFormValid)
            }
        }
        .navigationTitle("Sign Up")
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && password == passwordConfirm
    }
    
    private func handleSignup() {
        isLoading = true
        // Implement signup logic
        isLoading = false
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}

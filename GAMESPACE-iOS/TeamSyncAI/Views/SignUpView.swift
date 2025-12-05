import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                TextField("Full Name", text: $fullName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            Button(action: {
                authVM.signup(email: email, password: password, fullName: fullName)
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}

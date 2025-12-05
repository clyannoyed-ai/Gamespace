import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("TeamSync AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Button(action: {
                    authVM.login(email: email, password: password)
                }) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
            .alert("Error", isPresented: $authVM.showError) {
                Button("OK") { }
            } message: {
                Text(authVM.errorMessage)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

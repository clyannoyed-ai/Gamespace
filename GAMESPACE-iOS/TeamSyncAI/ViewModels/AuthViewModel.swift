import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userEmail = ""
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let networkManager = NetworkManager()
    
    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        let credentials = ["email": email, "password": password]
        networkManager.post(endpoint: "/auth/login", body: credentials) { (result: Result<LoginResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.userEmail = email
                    self.isLoggedIn = true
                    UserDefaults.standard.set(response.token, forKey: "authToken")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    func signup(email: String, password: String, fullName: String) {
        guard !email.isEmpty, !password.isEmpty, !fullName.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        let userData = ["email": email, "password": password, "fullName": fullName]
        networkManager.post(endpoint: "/auth/signup", body: userData) { (result: Result<LoginResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.userEmail = email
                    self.isLoggedIn = true
                    UserDefaults.standard.set(response.token, forKey: "authToken")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    func logout() {
        isLoggedIn = false
        userEmail = ""
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
}

struct LoginResponse: Codable {
    let token: String
    let user: User
}

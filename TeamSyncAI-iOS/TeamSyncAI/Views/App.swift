import SwiftUI

@main
struct TeamSyncAIApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}

// MARK: - Authentication Manager

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentTeam: Team?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let keychain = KeychainManager.shared
    
    private init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    private func checkAuthStatus() async {
        // Try to restore auth token from Keychain
        if let token = keychain.getToken(forKey: SecureStorageKey.authToken) {
            APIService.shared.setAuthToken(token)
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        }
    }
    
    func login(email: String, password: String) async throws {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }
        
        do {
            // Call login endpoint - replace with actual endpoint
            // let response: AuthResponse = try await APIService.shared.request(...)
            
            // Mock response for now
            let mockToken = "token_\(UUID().uuidString)"
            let mockUser = User(
                id: "user_\(UUID().uuidString)",
                email: email,
                name: email.components(separatedBy: "@").first ?? "User",
                role: .parent,
                profilePhoto: nil,
                phone: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            // Save token securely
            _ = keychain.saveToken(mockToken, forKey: SecureStorageKey.authToken)
            APIService.shared.setAuthToken(mockToken)
            
            await MainActor.run {
                self.currentUser = mockUser
                self.isAuthenticated = true
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Login failed: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    func logout() {
        keychain.clearAllTokens()
        APIService.shared.setAuthToken("")
        
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
            self.currentTeam = nil
        }
    }
}

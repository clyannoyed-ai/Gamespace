import Foundation

// MARK: - Configuration Constants

struct Config {
    // MARK: - Environment Detection
    static let isDebug = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    // MARK: - Backend Configuration
    
    /// Backend API Base URL
    static let apiBaseURL: URL = {
        if isDebug {
            // Development - Local or staging
            return URL(string: "http://localhost:3000/api/v1") ?? 
                   URL(string: "https://dev-backend.teamsyncai.app/api/v1")!
        } else {
            // Production
            return URL(string: "https://teamsyncai.abacusai.app/api/v1")!
        }
    }()
    
    /// Supabase Configuration
    static let supabaseURL = URL(string: "https://[YOUR_PROJECT_ID].supabase.co")!
    static let supabaseAnonKey = "[YOUR_ANON_KEY]"
    
    // MARK: - App Configuration
    
    static let appName = "TeamSync AI"
    static let appVersion = "1.0.0"
    static let minimumIOSVersion = "15.0"
    
    // MARK: - Feature Flags
    
    static let enableOfflineMode = false  // Phase 2
    static let enablePushNotifications = true
    static let enableVoiceChat = true
    static let enableBiometricAuth = false  // Phase 2
    
    // MARK: - API Configuration
    
    static let apiRequestTimeout: TimeInterval = 30.0
    static let apiMaxRetries = 3
    
    // MARK: - Notification Configuration
    
    static let defaultEventReminderMinutes = 60
    static let notificationSoundEnabled = true
    
    // MARK: - Logging
    
    static let enableNetworkLogging = isDebug
    static let enableConsoleLogging = isDebug
}

// MARK: - Secure Storage Keys

struct SecureStorageKey {
    static let authToken = "com.teamsyncai.auth.token"
    static let refreshToken = "com.teamsyncai.auth.refreshToken"
    static let userId = "com.teamsyncai.user.id"
    static let userEmail = "com.teamsyncai.user.email"
}

// MARK: - App Identifiers

struct AppIdentifiers {
    static let bundleIdentifier = "com.teamsyncai.app"
    static let organizationIdentifier = "com.teamsyncai"
    static let teamIdentifier = "YOUR_TEAM_ID"  // Replace with your Apple Team ID
}

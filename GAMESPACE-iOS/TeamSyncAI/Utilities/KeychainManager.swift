import Foundation
import Security

// MARK: - Keychain Manager for Secure Token Storage

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    /// Save token securely in Keychain
    func saveToken(_ token: String, forKey key: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Delete existing if any
        SecItemDelete(query as CFDictionary)
        
        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve token from Keychain
    func getToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    /// Delete token from Keychain
    func deleteToken(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    /// Clear all tokens
    func clearAllTokens() {
        deleteToken(forKey: SecureStorageKey.authToken)
        deleteToken(forKey: SecureStorageKey.refreshToken)
        deleteToken(forKey: SecureStorageKey.userId)
    }
}

// MARK: - UserDefaults Extensions (Non-sensitive data)

extension UserDefaults {
    func setJSON<T: Encodable>(_ value: T?, forKey key: String) {
        if let value = value {
            if let encoded = try? JSONEncoder().encode(value) {
                set(encoded, forKey: key)
            }
        } else {
            removeObject(forKey: key)
        }
    }
    
    func getJSON<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

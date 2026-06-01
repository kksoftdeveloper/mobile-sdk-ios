//
//  KeychainManager.swift
//  AuthSDKExample
//
//  Created by Damon on 4/18/25.
//

import Foundation
import Security
import AuthSDK

class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    func save(_ data: Data, forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String:           kSecClassGenericPassword,
            kSecAttrAccount as String:     key,
            kSecValueData as String:       data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String:           kSecClassGenericPassword,
            kSecAttrAccount as String:     key,
            kSecReturnData as String:      true,
            kSecMatchLimit as String:      kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else { return nil }
        return dataTypeRef as? Data
    }
    
    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String:           kSecClassGenericPassword,
            kSecAttrAccount as String:     key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

extension KeychainManager {
    private var sessionKey: String { "authSession" }
    
    func saveAuthSession(_ session: AuthSessionResponse) {
        if let data = try? JSONEncoder().encode(session) {
            save(data, forKey: sessionKey)
        }
    }
    
    func loadAuthSession() -> AuthSessionResponse? {
        guard let data = load(forKey: sessionKey),
              let session = try? JSONDecoder().decode(AuthSessionResponse.self, from: data) else {
            return nil
        }
        return session
    }
    
    func clearAuthSession() {
        delete(forKey: sessionKey)
    }
}

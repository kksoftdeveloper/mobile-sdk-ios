//
//  SecureStorage.swift
//  AuthSDK
//

import Foundation
import AuthSDK

struct KeyChainSessionManager: SessionManager {

    private let service = "com.dar.paymentsdk.data.storage.session"
    private let account = "Session"
    
    // AuthSDK's session manager for syncing tokens
    private let authSDKSessionManager = AuthSDK.KeyChainSessionManager()
    
    func saveSession(authSession: AuthSessionModel, isRefreshToken: Bool = false, refreshTokenDTO: PaymentSessionServerDTO? = nil) throws {
        print("----> Saving session")
        let sessionData = try JSONEncoder().encode(authSession)
        print("----> Saving session 2: \(sessionData)")
        print(String(data: sessionData, encoding: .utf8) ?? "Error converting to Data")
        try KeychainHelper.shared.save(sessionData, service: service, account: self.account)
        print("----> Saving session saved: \(sessionData)")
        if isRefreshToken {
            // Sync tokens to AuthSDK's sessionManager when refreshing
            print("----> Syncing tokens to AuthSDK sessionManager")
            syncToAuthSDKSession(authSession: authSession, refreshTokenDTO: refreshTokenDTO)
            
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: NSNotification.Name(DefaultPaymentManager.REFERSH_TOKEN_KEY), object: authSession.toOutput())
            print("----> Saving session refresh token posted")
        }
    }
    
    /// Sync PaymentSDK's auth session to AuthSDK's sessionManager
    private func syncToAuthSDKSession(authSession: AuthSessionModel, refreshTokenDTO: PaymentSessionServerDTO?) {
        do {
            // Try to get existing AuthSDK session to preserve other fields
            var authSDKSession: AuthSDK.AuthSessionModel? = try authSDKSessionManager.getSession()
            
            // Parse expireDate from DTO if available
            let expireDate: Date
            let refreshExpireDate: Date?
            
            if let dto = refreshTokenDTO {
                // Parse expireDate string to Date
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                expireDate = dateFormatter.date(from: dto.expireDate) ?? Date().addingTimeInterval(3600)
                
                // Parse refreshExpireDate if available
                if let refreshExpireDateString = dto.refreshExpireDate {
                    refreshExpireDate = dateFormatter.date(from: refreshExpireDateString) ?? Date().addingTimeInterval(3600 * 24 * 30) // 30 days default
                } else {
                    refreshExpireDate = Date().addingTimeInterval(3600 * 24 * 30) // 30 days default
                }
            } else {
                // Fallback to default expiry if DTO not available
                expireDate = Date().addingTimeInterval(3600) // 1 hour default
                refreshExpireDate = Date().addingTimeInterval(3600 * 24 * 30) // 30 days default
            }
            
            if let existingSession = authSDKSession {
                // Update existing session with new tokens and gameUUID
                // Preserve other fields but update expireDate from DTO
                authSDKSession = existingSession.copy(
                    gameUUID: authSession.gameUUID,
                    accessToken: authSession.accessToken,
                    refreshToken: authSession.refreshToken,
                    expireDate: expireDate,
                    refreshExpireDate: refreshExpireDate
                )
            } else {
                // Create new AuthSDK session with fields from DTO
                authSDKSession = AuthSDK.AuthSessionModel(
                    gameUUID: authSession.gameUUID,
                    serverId: refreshTokenDTO?.serverId,
                    accessToken: authSession.accessToken,
                    refreshToken: authSession.refreshToken,
                    expireDate: expireDate,
                    isNewUser: refreshTokenDTO?.isNewUser,
                    refreshExpireDate: refreshExpireDate,
                    userBlocked: refreshTokenDTO?.userBlocked,
                    gameBlocked: refreshTokenDTO?.gameBlocked,
                    serverBlocked: refreshTokenDTO?.serverBlocked,
                    loginReminder: nil
                )
            }
            
            if let sessionToSave = authSDKSession {
                try authSDKSessionManager.saveSession(authSession: sessionToSave, isRefreshToken: true)
                print("----> ✅ Successfully synced tokens to AuthSDK sessionManager")
            }
        } catch {
            print("----> ⚠️ Failed to sync tokens to AuthSDK sessionManager: \(error)")
            // Don't throw - PaymentSDK session is already saved, this is just a sync
        }
    }
    
    func getSession() throws -> AuthSessionModel? {
        guard let data = try KeychainHelper.shared.load(service: service, account: self.account) else {
            return nil
        }
        return try JSONDecoder().decode(AuthSessionModel.self, from: data)
        
    }
    
    func clear() throws {
        try KeychainHelper.shared.delete(service: service, account: self.account)
    }
}

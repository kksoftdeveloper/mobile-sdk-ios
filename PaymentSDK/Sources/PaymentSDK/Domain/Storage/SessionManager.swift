//
//  SessionManager.swift
//  AuthSDK
//

import Foundation

protocol SessionManager {
    func saveSession(authSession: AuthSessionModel, isRefreshToken: Bool, refreshTokenDTO: PaymentSessionServerDTO?) throws
    func getSession() throws -> AuthSessionModel?
    func clear() throws
}

// Extension to provide default parameter values
extension SessionManager {
    func saveSession(authSession: AuthSessionModel, isRefreshToken: Bool = false) throws {
        try saveSession(authSession: authSession, isRefreshToken: isRefreshToken, refreshTokenDTO: nil)
    }
}

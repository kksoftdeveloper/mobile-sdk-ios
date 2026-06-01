//
//  AuthSessionModel.swift
//  PaymentSDK
//
//  Created by X on 5/6/25.
//

import Foundation

struct AuthSessionModel: Codable {
    let gameUUID: String
    let accessToken: String
    let refreshToken: String
}

extension AuthSessionInput {
    func toModel() -> AuthSessionModel {
        return .init(
            gameUUID: gameUUID,
            accessToken: accessToken,
            refreshToken: refreshToken)
    }
}

extension AuthSessionModel {
    func toOutput() -> AuthSessionOutput {
        return AuthSessionOutput(
            gameUUID: self.gameUUID,
            accessToken: self.accessToken,
            refreshToken: self.refreshToken
        )
    }
}

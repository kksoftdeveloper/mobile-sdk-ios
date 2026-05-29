//
//  AuthSDKConfig.swift
//  AuthSDK
//

import Foundation

public struct AuthInitResponse: Codable {
    public let gameInfo: GameInfoResponse
    public let versionInfo: VersionInfoResponse
    public let guestLoginAfterSeconds: Int64?
    
    private enum CodingKeys: String, CodingKey {
        case gameInfo = "game"
        case versionInfo
        case guestLoginAfterSeconds = "guestLoginAfterSeconds"
    }
}

//
//  GameInfo.swift
//  AuthSDK
//

import Foundation

public struct GameInfoResponse: Codable {
    public let gameId: Int
    public let gameName: String
    
    private enum CodingKeys: String, CodingKey {
        case gameId = "gameId"
        case gameName = "gameName"
    }
}

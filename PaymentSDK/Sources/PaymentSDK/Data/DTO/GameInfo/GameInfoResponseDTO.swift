//
//  GameInfo.swift
//  AuthSDK
//

import Foundation


struct GameInfoResponseDTO: Decodable {
    
    let gameId: Int
    let gameName: String
    let status: GameStatusDTO
    
    enum GameStatusDTO: String, Codable {
        case active = "ACTIVE"
        case inactive = "INACTIVE"
    }
}

extension GameInfoResponseDTO.GameStatusDTO {
    func toModel() -> GameStatus {
        switch self {
        case .active:
            return .active
        case .inactive:
            return .inactive
        }
    }
}

extension GameInfoResponseDTO {
    
    func toModel() -> GameInfoModel {
        return GameInfoModel(
            gameID: gameId,
            gameName: "Demo",
            status: status.toModel(),
            serverID: "1",
            gameUUID: "12",
            packageName: "wqqw",
            appVersion: "1.0.0"
        )
    }
}

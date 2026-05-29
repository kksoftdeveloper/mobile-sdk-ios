//
//  GameInfoModel.swift
//  AuthSDK
//

import Foundation

struct GameInfoModel {
    let gameId: Int
    let gameName: String
    let status: GameStatus
}

extension GameInfoModel {
    func toResponse() -> GameInfoResponse {
        return GameInfoResponse(gameId: gameId, gameName: gameName)
    }
}

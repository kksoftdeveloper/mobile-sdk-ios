//
//  GameInfoModel.swift
//  PaymentSDK
//
//  Created by X on 5/6/25.
//


import Foundation

struct GameInfoModel {
    let gameID: Int
    let gameName: String
    let status: GameStatus
    let serverID: String
    let gameUUID: String
    let packageName: String
    let appVersion: String
}

extension GameInfoModel {
    func toOutput() -> GameInfoOutput {
        return GameInfoOutput(gameId: gameID,
                              gameName: gameName,
                              status: status.rawValue)
    }
}


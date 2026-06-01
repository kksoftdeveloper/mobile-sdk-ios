//
//  GameInfoManager.swift
//  AuthSDK
//

import Foundation

protocol GameInfoStorage {
    
    var gameUUID: String? { get set }
    var gameID: Int? { get set }
    var serverID: String? { get set }
    var serverName: String? { get set }
    var characterId: String? { get set }
    var appVersion: String? { get set }
    var packageName: String? { get set }
    
    func clear()
}

//
//  DefaultGameInfoStorage.swift
//  PaymentSDK
//
//  Created by X on 5/6/25.
//

import Foundation

final class DefaultGameInfoStorage: GameInfoStorage {
    
    var appVersion: String? {
        get { defaults.string(forKey: Keys.appVersion) }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: Keys.appVersion)
            } else {
                defaults.removeObject(forKey: Keys.appVersion)
            }
        }
    }
    
    var gameUUID: String? {
        get { defaults.string(forKey: Keys.gameUUID) }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: Keys.gameUUID)
            } else {
                defaults.removeObject(forKey: Keys.gameUUID)
            }
        }
    }
    
    var gameID: Int? {
        get { defaults.integer(forKey: Keys.gameID) }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: Keys.gameID)
            } else {
                defaults.removeObject(forKey: Keys.gameID)
            }
        }
    }
    
    var serverID: String? {
        get { defaults.string(forKey: Keys.serverID) }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: Keys.serverID)
            } else {
                defaults.removeObject(forKey: Keys.serverID)
            }
        }
    }

    var serverName: String? {
        get { defaults.string(forKey: Keys.serverName) }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: Keys.serverName)
            } else {
                defaults.removeObject(forKey: Keys.serverName)
            }
        }
    }
    
    var characterId: String? {
        get { defaults.string(forKey: Keys.characterId) }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: Keys.characterId)
            } else {
                defaults.removeObject(forKey: Keys.characterId)
            }
        }
    }
    
    var packageName: String? {
        get { defaults.string(forKey: Keys.packageName) }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: Keys.packageName)
            } else {
                defaults.removeObject(forKey: Keys.packageName)
            }
        }
    }
    
    func clear() {
        defaults.removeObject(forKey: Keys.gameUUID)
        defaults.removeObject(forKey: Keys.gameID)
        defaults.removeObject(forKey: Keys.serverID)
        defaults.removeObject(forKey: Keys.serverName)
    }
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    private enum Keys {
        static let gameID = "app.gameID"
        static let serverID = "app.serverID"
        static let serverName = "app.serverName"
        static let packageName = "app.packageName"
        static let characterId = "app.characterId"
        static let gameUUID = "app.gameUUID"
        static let appVersion = "app.version"
    }
}

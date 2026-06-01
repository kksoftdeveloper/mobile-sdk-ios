//
//  SignatureSHA256.swift
//  AuthSDK
//

import Foundation
import CryptoKit

final class SHA256Signature: Signature, SDKInfo {
    
    func sign(timestampInSeconds: Int) throws -> String {
        guard let packageName = appInfoStorage.packageName else {
            throw PaymentError.sdkNotInitialized()
        }
        guard let deviceID = try? deviceInfoStorage.getDeviceId() else {
            throw PaymentError.sdkNotInitialized()
        }
        
        let combined = "\(deviceID)|\(packageName)|\(timestampInSeconds)|\(deviceSecretKey)"
        
        return sha256Base64Safe(combined)
    }
    
    /**
     sku|price|gameId|serverId|platform|appVersion|sdkVersion|secretKey
     validate game package
     */
    func sign(sku: String, price: Int, serverId: String) throws -> String {
        guard let gameID = gameInfoStorage.gameID, let appVersion = gameInfoStorage.appVersion, let gameUUID = gameInfoStorage.gameUUID else {
            throw PaymentError.sdkNotInitialized()
        }
        
        let combined = "\(sku)|\(price)|\(gameID)|\(serverId)|\(platform)|\(appVersion)|\(versionName)|\(deviceSecretKey)"
        return sha256Base64Safe(combined)
    }
    
    /**
     sku|transactionId|gameId|serverId|platform|appVersion|sdkVersion|secretKey
     verify game package purchase
     */
    func sign(sku: String, transactionId: String, serverId: String, purchaseToken: String) throws -> String {
        guard let gameID = gameInfoStorage.gameID, let appVersion = gameInfoStorage.appVersion else {
            throw PaymentError.sdkNotInitialized()
        }
        
        let combined = "\(sku)|\(transactionId)|\(gameID)|\(serverId)|\(platform)|\(appVersion)|\(versionName)|\(deviceSecretKey)"
        return sha256Base64Safe(combined)
    }
    
    func sign(refreshToken: String) throws -> String {
        guard let appVersion = gameInfoStorage.appVersion else {
            throw PaymentError.sdkNotInitialized()
        }
        guard let deviceID = try? deviceInfoStorage.getDeviceId() else {
            throw PaymentError.sdkNotInitialized()
        }
        let combined = "\(deviceID)|\(platform)|\(versionName)|\(appVersion)|\(refreshToken)|\(deviceSecretKey)"
        return sha256Base64Safe(combined)
    }
    
    private func sha256Base64Safe(_ combined: String) -> String {
        print("combined: \(combined)")

        let inputData = Data(combined.utf8)
        let hash = SHA256.hash(data: inputData)
        let hashData = Data(hash)
        var base64 = hashData.base64EncodedString()
        base64 = base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return base64
    }
    
    private var gameInfoStorage: GameInfoStorage
    private var appInfoStorage: AppInfoStorage
    private var deviceInfoStorage: DeviceInfoStorage
    
    init(gameInfoStorage: GameInfoStorage = DefaultGameInfoStorage(),
         appInfoStorage: AppInfoStorage = DefaultAppInfoStorage(),
         deviceInfoStorage: DeviceInfoStorage = DeviceInfoKeychainStorage()
    ) {
        self.gameInfoStorage = gameInfoStorage
        self.appInfoStorage = appInfoStorage
        self.deviceInfoStorage = deviceInfoStorage
    }
}

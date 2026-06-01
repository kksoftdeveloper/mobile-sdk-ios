//
//  Signature.swift
//  AuthSDK
//

import Foundation

protocol Signature {
    // for get game-info request body
    func sign(timestampInSeconds: Int) throws -> String
    func sign(sku: String, price: Int, serverId: String) throws -> String 
    func sign(sku: String, transactionId: String, serverId: String, purchaseToken: String) throws -> String
    // refresh token
    // deviceId|platform|sdkVersion|appVersion|refreshToken|secretKey
    func sign(refreshToken: String) throws -> String
}

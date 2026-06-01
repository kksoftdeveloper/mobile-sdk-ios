//
//  DefaultInitializer.swift
//  PaymentSDK
//
//  Created by X on 5/6/25.
//

import Foundation
import Combine

final class DefaultInitializer: Initialializer, SDKInfo {
    
    private var apiClient: PaymentAPIClient
    private var gameInfoStorage: GameInfoStorage
    private var appInfoStorage: AppInfoStorage
    private var deviceInfoStorage: DeviceInfoStorage
    private var signature: Signature
    
    init(apiClient: PaymentAPIClient,
         gameInfoStorage: GameInfoStorage = DefaultGameInfoStorage(),
         appInfoStorage: AppInfoStorage = DefaultAppInfoStorage(),
         deviceInfoStorage: DeviceInfoStorage = DeviceInfoKeychainStorage(),
         signature: Signature = SHA256Signature()
    ) {
        self.apiClient = apiClient
        self.gameInfoStorage = gameInfoStorage
        self.appInfoStorage = appInfoStorage
        self.deviceInfoStorage = deviceInfoStorage
        self.signature = signature
    }

    func initSDK() -> AnyPublisher<DatalessOutput, Error> {
        
        guard let packageName = appInfoStorage.packageName else {
            return Fail(error: PaymentError.sdkNotInitialized()).eraseToAnyPublisher()
        }
        
        guard let appVersion = appInfoStorage.appVersion else {
            return Fail(error: PaymentError.sdkNotInitialized()).eraseToAnyPublisher()
        }
        
        guard let deviceId: String = try? deviceInfoStorage.getDeviceId() else {
            return Fail(error: PaymentError.sdkNotInitialized()).eraseToAnyPublisher()
        }
        
        let timeStamp = Int(Date().timeIntervalSince1970)
        
        guard let signature = try? self.signature.sign(timestampInSeconds: timeStamp) else {
            return Fail(error: PaymentError.sdkNotInitialized()).eraseToAnyPublisher()
        }
        
        let body = InitSDKRequestBody(
            packageName: packageName,
            deviceId: deviceId,
            platform: platform,
            sdkVersion: versionName,
            appVersion: appVersion,
            timestamp: timeStamp,
            sign: signature
        )
        
        return apiClient.initSDK(body: body)
            .tryMap { initResDTO in
                
                return DatalessOutput(status: 1, message: "Success")
            }
            .eraseToAnyPublisher()
    }
}

struct InitSDKRequestBody: Encodable {
    let packageName: String
    let deviceId: String
    let platform: String
    let sdkVersion: String
    let appVersion: String
    let timestamp: Int
    let sign: String
    
    private enum CodingKeys: String, CodingKey {
        case packageName = "packageName"
        case deviceId = "deviceId"
        case platform = "platform"
        case sdkVersion = "sdkVersion"
        case appVersion = "appVersion"
        case timestamp = "timestamp"
        case sign = "sign"
    }
}

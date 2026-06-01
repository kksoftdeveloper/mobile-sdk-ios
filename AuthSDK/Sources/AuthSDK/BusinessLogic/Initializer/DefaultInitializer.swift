//
//  Initializer.swift
//  AuthSDK
//

import Foundation
import Combine

final class DefaultInitializer : InitializeAnalytics, Initialializer, DeviceIdentifiable, SDKInfo {
    
    private var authAPIClient: AuthAPIClient
    private var gameInfoStorage: GameInfoStorage
    private var signature: Signature
    
    init(authAPIClient: AuthAPIClient,
         gameInfoStorage: GameInfoStorage = DefaultGameInfoStorage(),
         signature: Signature = SHA256Signature()
    ) {
        self.authAPIClient = authAPIClient
        self.gameInfoStorage = gameInfoStorage
        self.signature = signature
    }
    
    func initSDK(packageName: String, appVersion: String, serverId: String) -> AnyPublisher<AuthInitResponse, Error> {
        let timeStamp = Int(Date().timeIntervalSince1970)
        
        gameInfoStorage.packageName = packageName
        gameInfoStorage.appVersion = appVersion
        
        guard let signature = try? self.signature.sign(timestampInSeconds: timeStamp) else {
            Analytics.track(event: self.eventName, properties: [self.failure : AuthErrorResponse.sdkSignatureError().message])
            return Fail(error: AuthErrorResponse.sdkSignatureError()).eraseToAnyPublisher()
        }
        
//        gameInfoStorage.serverID = serverId
        
        let body = InitSDKRequestBody(
            packageName: packageName,
            deviceId: deviceID,
            platform: platform,
            sdkVersion: versionName,
            appVersion: appVersion,
            timestamp: timeStamp,
            sign: signature
        )
        
        Analytics.track(event: eventName, properties: [request : body.toDictionary().toMixpanelType()])
        return authAPIClient.initSDK(body: body)
            .tryMap { [weak self] initResDTO -> (response: AuthInitResponse, gameId: Int, serverId: String) in
                guard let self else { throw AuthErrorResponse.unknownError() }
                
                let model = initResDTO.data.toModel()
                
                self.gameInfoStorage.gameID = model.gameInfoModel?.gameId ?? 1
                self.gameInfoStorage.packageName = packageName
                self.gameInfoStorage.appVersion = appVersion
                self.gameInfoStorage.timeToRemindLogin = initResDTO.data.guestLoginAfterSeconds ?? 0
                
                if let fbClientID = model.facebookConfigModel?.clientId {
                    try SensitiveDataManager.shared.set(fbClientID, for: .facebookClientID)
                }
                if let fbSecretClient = model.facebookConfigModel?.clientToken {
                    try SensitiveDataManager.shared.set(fbSecretClient, for: .facebookClientSecret)
                }
                if let ggClientID = model.googleConfigModel?.clientId {
                    try SensitiveDataManager.shared.set(ggClientID, for: .googleClientID)
                }
                if let ggURLSchema = model.googleConfigModel?.platformUrlSchema {
                    try SensitiveDataManager.shared.set(ggURLSchema, for: .googleURLSchema)
                }
                
                guard let response = try model.toResponse() else {
                    Analytics.track(event: self.eventName, properties: [self.failure : "Serialization Error"])
                    throw AuthErrorResponse.appNotFound()
                }
                
                Analytics.track(event: self.eventName, properties: [self.success : response.toDictionary().toMixpanelType()])
                let gameId = response.gameInfo.gameId
                print("SERVER: given-server = \(serverId)")
                print("SERVER: set-gameId \(gameId)")
                return (response, gameId, serverId)
            }
            .flatMap { [weak self] pair -> AnyPublisher<AuthInitResponse, Error> in
                guard let self else {
                    print("SERVER: self = nil")
                    return Fail(error: AuthErrorResponse.unknownError()).eraseToAnyPublisher()
                }
                let (response, gameId, serverId) = pair
                print("SERVER: pair = \(pair)")
                return self.authAPIClient.getGameServers(gameId: gameId)
                    .tryMap { resDTO in
                        let ret = resDTO.data.map { dto in
                            dto.toModel().toResponse()
                        }
                        print("SERVER: Server List = \(ret)")
                        return ret
                    }
                    .tryMap { (servers: [GameServerInfoResponse]) -> AuthInitResponse in
                        guard !servers.isEmpty else {
                            let notificationCenter = NotificationCenter.default
                            notificationCenter.post(name: NSNotification.Name(NotificationKeys.SERVER_MAINTENANCE_KEY), object: nil)
                            throw AuthErrorResponse.appNotConfiguredGameServer()
                        }
                        print("SERVER: Selected ServerId = \(serverId)")
                        let selectSerObj = servers.first { $0.serverClientId?.lowercased() == serverId.lowercased() }
                        if let selectedSer = selectSerObj {
                            print("SERVER: Selected Server = \(selectedSer.serverId)")
                            self.gameInfoStorage.serverID = selectedSer.serverId
                            self.gameInfoStorage.serverName = selectedSer.serverName
                        } else {
                            self.gameInfoStorage.serverID = nil
                            self.gameInfoStorage.serverName = nil
                            let notificationCenter = NotificationCenter.default
                            notificationCenter.post(name: NSNotification.Name(NotificationKeys.SERVER_MAINTENANCE_KEY), object: nil)
                        }
//                        guard servers.contains(where: {
//                            print("Selected compaired to selected server: \($0.serverId) & \(serverId.lowercased())")
//                            isGoodGivenServerId = $0.serverId.lowercased() == serverId.lowercased()
//                            
//                        }) else {
//                            let notificationCenter = NotificationCenter.default
//                            notificationCenter.post(name: NSNotification.Name(NotificationKeys.SERVER_MAINTENANCE_KEY), object: nil)
//                            throw AuthErrorResponse.appNotConfiguredGameServer()
//                        }
                        return response
                    }
                    .eraseToAnyPublisher()
            }
            .mapError { [weak self] error -> Error in
                self?.trackAndWrap(error) ?? error
            }
            .eraseToAnyPublisher()
    }

    @discardableResult
    private func trackAndWrap(_ error: Error) -> Error {
        let domainError: Error
        if let e = error as? AuthErrorResponse {
            domainError = e
        } else {
            domainError = AuthErrorResponse.unknownError()
        }
        Analytics.track(event: eventName, properties: [failure: "\(domainError)"])
        return domainError
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

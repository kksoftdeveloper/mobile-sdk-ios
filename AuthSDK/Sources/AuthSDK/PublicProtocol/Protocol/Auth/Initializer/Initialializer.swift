//
//  Initialializer.swift
//  AuthSDK
//

import Foundation
import Combine



public protocol Initialializer {
    func initSDK(packageName: String, appVersion: String, serverId: String) -> AnyPublisher<AuthInitResponse, Error>
}

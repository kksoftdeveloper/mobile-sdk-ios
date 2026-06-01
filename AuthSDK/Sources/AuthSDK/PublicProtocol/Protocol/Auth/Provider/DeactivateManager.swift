//
//  DeactivateManager.swift
//  AuthSDK
//
//  Created by X on 6/2/25.
//

import Foundation
import Combine

public protocol DeactivateManager {
    func deactivateAccount() -> AnyPublisher<DatalessResponse, Error>
}


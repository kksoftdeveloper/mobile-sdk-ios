//
//  Initialializer.swift
//  AuthSDK
//

import Foundation
import Combine

public protocol Initialializer {
    func initSDK() -> AnyPublisher<DatalessOutput, Error>
}

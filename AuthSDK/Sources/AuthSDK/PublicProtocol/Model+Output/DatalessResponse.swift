//
//  DatalessResponse.swift
//  AuthSDK
//
//  Created by X on 4/30/25.
//

import Foundation

public struct DatalessResponse: Codable, Equatable, Hashable {
    let status: Int
    let message: String
}

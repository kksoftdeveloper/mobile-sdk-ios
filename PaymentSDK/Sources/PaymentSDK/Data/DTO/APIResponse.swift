//
//  File.swift
//  AuthSDK
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let status: Int
    let data: T
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case status, data, message
    }
}

struct DataEmptynessResponse: Decodable { }

extension DataEmptynessResponse {
    func toModel() -> DataEmptynessModel {
        return DataEmptynessModel()
    }
}

struct DatalessResponse: Decodable {
    let status: Int
    let message: String
}

extension DatalessResponse {
    func toModel() -> DatalessModel {
        return DatalessModel(
            status: status,
            message: message
        )
    }
}

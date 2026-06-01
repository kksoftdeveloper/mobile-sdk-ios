//
//  EmptyModel.swift
//  AuthSDK
//
//  Created by X on 4/30/25.
//

import Foundation



struct DatalessModel: Decodable {
    let status: Int
    let message: String
}

extension DatalessModel {
    
    func toResponse() -> DatalessResponse {
        return DatalessResponse(status: status, message: message)
        
    }
}

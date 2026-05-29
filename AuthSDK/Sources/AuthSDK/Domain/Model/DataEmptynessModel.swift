//
//  DataEmptyModel.swift
//  AuthSDK
//
//  Created by X on 4/30/25.
//

import Foundation

struct DataEmptynessModel: Decodable { }

extension DataEmptynessModel {
    
    func toResponse() -> DataEmptynessResponse{
        return DataEmptynessResponse()
    }
}

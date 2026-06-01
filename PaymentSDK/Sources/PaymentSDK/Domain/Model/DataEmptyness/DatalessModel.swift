//
//  DatalessResponse.swift
//  PaymentSDK
//
//  Created by X on 5/6/25.
//

import Foundation


struct DatalessModel: Decodable {
    let status: Int
    let message: String
}

extension DatalessModel {
    
    func toOutput() -> DatalessOutput {
        return DatalessOutput(status: status, message: message)
        
    }
}

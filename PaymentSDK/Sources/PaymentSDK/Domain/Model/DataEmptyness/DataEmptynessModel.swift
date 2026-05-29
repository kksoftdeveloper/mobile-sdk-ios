//
//  DataEmptynessModel.swift
//  PaymentSDK
//
//  Created by X on 5/6/25.
//

import Foundation

struct DataEmptynessModel: Decodable { }

extension DataEmptynessModel {
    func toOutput() -> DataEmptynessOutput{
        return DataEmptynessOutput()
    }
}

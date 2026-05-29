//
//  GamePlayerStorage.swift
//  PaymentSDK
//
//  Created by X on 5/6/25.
//

import Foundation

protocol GamePlayerStorage {
    func savePhoneNumber(_ phoneNumber: String) throws
    func getPhoneNumber() throws -> String?
    
    func saveIsGuestUser(_ isGuestUser: Bool) throws
    func getIsGuestUser() throws -> Bool
    
    func clear() throws
}

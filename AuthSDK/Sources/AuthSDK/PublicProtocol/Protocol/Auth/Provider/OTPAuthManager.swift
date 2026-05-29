//
//  PhoneAuthManager.swift
//  AuthSDK
//

import Foundation
import Combine

public protocol OTPAuthManager {
    func requestOTP(phone: String) -> AnyPublisher<OTPSendableResponse, Error>
    
    func verifyOTP(code: String) -> AnyPublisher<OTPVerifiableResponse , Error>

    func logout()  -> AnyPublisher<DatalessResponse, Error> 
    
    func isAuthenticated() -> Bool
    
    func getPhoneNumber() throws -> String? 
}

//
//  SignupManager.swift
//  AuthSDK
//

import Foundation
import Combine

public protocol SignupManager {
    func signup(phone: String, password: String, otpVerifiedToken: String?) -> AnyPublisher<AuthSessionResponse, Error>
    func linkToNewAccount(phone: String, password: String, otpVerifiedToken: String?) -> AnyPublisher<AuthSessionResponse, Error>
    func getPhoneNumber() throws -> String?
    func getServerId() -> Int?
    func getGameId() -> Int?
}

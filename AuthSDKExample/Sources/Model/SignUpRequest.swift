//
//  SignUpRequest.swift
//  AuthSDK
//
//  Created by Damon on 4/10/25.
//

import Foundation

struct SignUpRequest: Codable, Equatable, Hashable {
    let phoneNunber: String
    let password: String
    let otpVerifiedToken: String
}

//
//  EmailLoginParameters.swift
//  AuthSDK
//

import Foundation

struct EmailLoginParameters: ValidatedLoginParameters {
    let provider = "email"
    let email: String
    let password: String

    func validate() throws {
        guard !email.isEmpty else {
            throw ValidationError.emailIsEmpty
        }
        guard !password.isEmpty else {
            throw ValidationError.passwordIsEmpty
        }
        guard email.isValidEmail() else {
            throw ValidationError.phoneIsEmpty
        }
    }
}

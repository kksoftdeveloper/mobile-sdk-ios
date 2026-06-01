//
//  FacebookLoginParameters.swift
//  AuthSDK
//

import Foundation

struct FacebookLoginParameters: ValidatedLoginParameters {
    let provider = "facebook"
    let clientID: String
    let clientSecret: String
    
    func validate() throws {
        guard !clientID.isEmpty else {
            throw ValidationError.facebookClientIDMissing
        }
        guard !clientSecret.isEmpty else {
            throw ValidationError.facebookClientSecretMissing
        }
    }
}

extension FacebookLoginParameters {
    static func fromSensitiveData() throws -> FacebookLoginParameters {
        guard let clientID = try SensitiveDataManager.shared.get(for: .facebookClientID) else {
            throw ValidationError.facebookClientIDMissing
        }
        guard let clientSecret = try SensitiveDataManager.shared.get(for: .facebookClientSecret) else {
            throw ValidationError.facebookClientSecretMissing
        }
        
        return FacebookLoginParameters(clientID: clientID, clientSecret: clientSecret)
    }
}

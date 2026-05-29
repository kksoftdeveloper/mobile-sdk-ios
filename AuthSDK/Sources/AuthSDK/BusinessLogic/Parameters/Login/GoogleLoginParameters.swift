//
//  GoogleLoginParameters.swift
//  AuthSDK
//

import Foundation

struct GoogleLoginParameters: ValidatedLoginParameters {
    let provider = "google"
    let clientID: String
    let clientURLSchema: String
    
    func validate() throws {
        guard !clientID.isEmpty else {
            throw ValidationError.googleClientIDMissing
        }
        guard !clientURLSchema.isEmpty else {
            throw ValidationError.googleSchemaURLMissing
        }
    }
}

extension GoogleLoginParameters {
    static func fromSensitiveData() throws -> GoogleLoginParameters {
        guard let clientID = try SensitiveDataManager.shared.get(for: .googleClientID) else {
            throw ValidationError.googleClientIDMissing
        }
        
        guard let urlSchema = try SensitiveDataManager.shared.get(for: .googleURLSchema) else {
            throw ValidationError.googleSchemaURLMissing
        }
        
        return GoogleLoginParameters(clientID: clientID, clientURLSchema: urlSchema)
    }
}

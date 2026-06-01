//
//  Environment.swift
//  AuthSDK
//
//  Created by Admin on 3/17/25.
//
import Foundation

enum Environment {
    case dev
    case staging
    case production

    public static var current: Environment {
        #if DEV
            return .dev
        #elseif STAGING
            return .staging
        #else
            return .production
        #endif
    }
}

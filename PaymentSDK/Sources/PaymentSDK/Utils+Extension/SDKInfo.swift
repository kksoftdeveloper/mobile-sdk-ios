//
//  SDKInfo.swift
//  AuthSDK
//

import Foundation
import AuthSDK

protocol SDKInfo {
    var platform: String { get }
    var versionName: String { get }
    var versionCode: String { get }
    var deviceSecretKey: String { get }
}

extension SDKInfo {
    
    var platform: String {
        return "iOS"
    }
    
    var versionName: String {
//        let dictionary = Bundle.main.infoDictionary
        return "1.0.0" //dictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var versionCode: String {
        let dictionary = Bundle.main.infoDictionary
        return dictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var deviceSecretKey: String {
        Environment.deviceSecretKey
    }
}

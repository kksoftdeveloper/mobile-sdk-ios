//
//  String+Localization.swift
//  AuthSDK
//
//  Created by Admin on 4/16/25.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

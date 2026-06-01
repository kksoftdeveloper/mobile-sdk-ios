//
//  FontLoaderObjCBridge.swift
//  UnityFramework
//
//  Created by Admin on 8/3/25.
//

import Foundation
import AuthSDK

@objc public class FontLoaderObjCBridge: NSObject {
    @objc public static func loadAllFonts() {
        AuthSDK.FontLoader.loadAllFonts()
    }
}

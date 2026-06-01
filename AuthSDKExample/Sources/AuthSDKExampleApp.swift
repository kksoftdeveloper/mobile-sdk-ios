//
//  AuthSDKExampleApp.swift
//  AuthSDKExample
//
//  Created by Admin on 3/19/25.
//

import SwiftUI
import AuthSDK

@main
struct AuthSDKExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
//            if(Environment.current == .dev) {
//                HomeDevView()
//            } else {
                AuthSDKDemoView(viewModel: AuthSDKDemoViewModel())
                    .preferredColorScheme(.light)
//            }
        }
    }
}



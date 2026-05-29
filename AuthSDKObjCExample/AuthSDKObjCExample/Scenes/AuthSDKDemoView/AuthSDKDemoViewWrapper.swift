//
//  AuthSDKDemoViewWrapper.swift
//  AuthSDKObjCExample
//
//  Created by Shinzo on 11/6/25.
//

import SwiftUI

@objc public class AuthSDKDemoViewWrapper: NSObject {
    @MainActor @objc public static func makeViewController() -> UIViewController {
        let viewModel = AuthSDKDemoViewModel()
        let view = AuthSDKDemoView(viewModel: viewModel)
        return UIHostingController(rootView: view)
    }
}

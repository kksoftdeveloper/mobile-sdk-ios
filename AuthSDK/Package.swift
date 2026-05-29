// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AuthSDK",
    platforms: [.iOS("15.0")],
    products: [
        .library(
            name: "AuthSDK",
            targets: ["AuthSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "8.0.0"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk.git", from: "18.0.0"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift.git", from: "5.0.0"),
        .package(path: "../TrackingSDK")
    ],

    targets: [
       .target(
            name: "AuthSDK",
            dependencies: [
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "FacebookLogin", package: "facebook-ios-sdk"),
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                .product(name: "TrackingSDK", package: "TrackingSDK")
            ],
            path: "Sources",
            sources: [
                "AuthSDK",
                "AuthSDKUI"
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("Localization.xcstrings"),
                .process("Fonts"),
                .process("Config.plist")
            ]
       ),
       .testTarget(
           name: "AuthSDKTests",
           dependencies: ["AuthSDK"],
           path: "Sources/AuthSDKTests"
       ),
    ]
)

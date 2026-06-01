// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TrackingSDK",
    platforms: [.iOS("15.0")],
    products: [
        .library(
            name: "TrackingSDK",
            targets: ["TrackingSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework.git", from: "6.15.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.5.0"),
        .package(url: "https://github.com/adjust/ios_sdk.git", from: "5.5.1"),
        .package(url: "https://github.com/tiktok/tiktok-business-ios-sdk.git", from: "1.6.1")
    ],
    targets: [
        .target(
            name: "TrackingSDK",
            dependencies: [
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalyticsCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "AdjustSdk", package: "ios_sdk"),
                .product(name: "TikTokBusinessSDK", package: "tiktok-business-ios-sdk")
            ],
            path: "Sources",
            sources: [
                "TrackingSDK"
            ],
            linkerSettings: [
                .linkedFramework("CoreTelephony")
            ]
        ),
        .testTarget(
            name: "TrackingSDKTests",
            dependencies: ["TrackingSDK"],
            path: "Sources/TrackingSDKTests"
        ),
    ]
)

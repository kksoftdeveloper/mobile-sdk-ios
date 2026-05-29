// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PaymentSDK",
    platforms: [.iOS("15.0")],
    products: [
        .library(
            name: "PaymentSDK",
            targets: ["PaymentSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mixpanel/mixpanel-swift.git", from: "5.0.0"),
        .package(path: "../AuthSDK"),
        .package(path: "../TrackingSDK")
    ],
    targets: [
        .target(
            name: "PaymentSDK",
            dependencies: [
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                .product(name: "AuthSDK", package: "AuthSDK"),
                .product(name: "TrackingSDK", package: "TrackingSDK")
            ],
            path: "Sources",
            sources: [
                "PaymentSDK",
                "PaymentSDKUI"
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("Localization.xcstrings"),
                .process("Fonts"),
                .process("Config.plist")
            ]
        ),
        .testTarget(
            name: "PaymentSDKTests",
            dependencies: ["PaymentSDK"],
            path: "Sources/PaymentSDKTests"
        ),
    ]
)

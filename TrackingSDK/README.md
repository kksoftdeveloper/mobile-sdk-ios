# TrackingSDK

A flexible, extensible tracking SDK for iOS that supports multiple tracking providers including AppFlyers, Firebase Analytics, Firebase Crashlytics, Adjust, and TikTok App Events.

## Features

- **Protocol-based architecture**: Easy to extend with new tracking providers
- **Multiple providers support**: Track events across multiple providers simultaneously
- **Unified API**: Single interface for all tracking operations
- **Extensible design**: Easy to add new providers (Firebase, Mixpanel, etc.)
- **Crashlytics support**: Built-in support for crash reporting

## Architecture

The SDK is built with a protocol-based architecture:

- `TrackingProvider`: Protocol for analytics providers (AppFlyers, Firebase Analytics, etc.)
- `CrashlyticsProvider`: Protocol for crash reporting providers (Firebase Crashlytics, etc.)
- `TrackingManager`: Main interface for tracking operations
- `DefaultTrackingManager`: Default implementation that routes events to all enabled providers

## Installation

Add TrackingSDK as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(path: "../TrackingSDK")
]
```

## Usage

### Basic Setup with AppFlyers

```swift
import TrackingSDK

// Initialize the tracking service
let trackingService = TrackingServiceProvider.Builder()
    .enableAppFlyers(appID: "your-app-id", devKey: "your-dev-key")
    .build()

// Initialize tracking
trackingService.trackingManager.initialize()

// Track events
trackingService.trackingManager.trackEvent("user_login", parameters: ["method": "email"])

// Track purchases
trackingService.trackingManager.trackPurchase(
    productID: "com.example.product",
    price: 9.99,
    currency: "USD",
    parameters: ["category": "premium"]
)

// Set user properties
trackingService.trackingManager.setUserProperties(["user_type": "premium", "level": 10])

// Set user ID
trackingService.trackingManager.setUserID("user123")
```

### Using Predefined Events

```swift
// Track predefined events
trackingService.trackingManager.trackEvent(.userLogin, parameters: ["method": "email"])
trackingService.trackingManager.trackEvent(.purchaseCompleted, parameters: ["product_id": "123"])
trackingService.trackingManager.trackEvent(.levelComplete, parameters: ["level": 5])
```

### Crashlytics

```swift
let trackingService = TrackingServiceProvider.Builder()
    .enableAppFlyers(appID: "your-app-id", devKey: "your-dev-key")
    .enableFirebaseCrashlytics()
    .build()

trackingService.trackingManager.initialize()

// Log messages
trackingService.trackingManager.log("User completed level 5")

// Record errors
do {
    try someOperation()
} catch {
    trackingService.trackingManager.recordError(error)
}

// Record custom exceptions
trackingService.trackingManager.recordException(
    name: "CustomException",
    reason: "Something went wrong",
    userInfo: ["key": "value"]
)
```

### Multiple Providers

```swift
// Enable multiple tracking providers
let trackingService = TrackingServiceProvider.Builder()
    .enableAppFlyers(appID: "app-id", devKey: "dev-key")
    .enableFirebaseAnalytics(appID: "firebase-app-id")
    .enableFirebaseCrashlytics()
    .enableTikTok(
        accessToken: "your-tiktok-access-token",
        appID: "your-ios-app-id",
        tiktokAppID: "your-tiktok-app-id"
    )
    .build()

// All events will be tracked across all enabled providers
trackingService.trackingManager.trackEvent("custom_event", parameters: nil)
```

### TikTok App Events

```swift
let trackingService = TrackingServiceProvider.Builder()
    .enableTikTok(
        accessToken: "your-tiktok-access-token",
        appID: "your-ios-app-id",
        tiktokAppID: "your-tiktok-app-id"
    )
    .build()

trackingService.trackingManager.initialize()
trackingService.trackingManager.trackEvent("level_start", parameters: ["level": 1])
trackingService.trackingManager.trackPurchase(
    productID: "com.example.coin_pack",
    price: 4.99,
    currency: "USD",
    parameters: ["source": "shop"]
)
```

TikTok user properties are merged into future event payloads. Do not include sensitive data in TikTok event properties. `setUserID(_:)` sends the value as TikTok's external user ID.

### Custom Providers

You can also add custom tracking providers:

```swift
class CustomTrackingProvider: TrackingProvider {
    // Implement TrackingProvider protocol
}

let customProvider = CustomTrackingProvider(appID: "id", devKey: "key")

let trackingService = TrackingServiceProvider.Builder()
    .addTrackingProvider(customProvider)
    .build()
```

## Adding Firebase Support

To add Firebase Analytics and Crashlytics:

1. Add Firebase dependency to `Package.swift` (TrackingSDK already uses `from: "12.5.0"`):
```swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.5.0")
]
```

2. Enable Firebase in your app:
```swift
.enableFirebaseAnalytics(appID: "your-firebase-app-id")
.enableFirebaseCrashlytics()
```

## Project Structure

```
TrackingSDK/
├── Sources/
│   └── TrackingSDK/
│       ├── Domain/
│       │   └── Protocol/
│       │       ├── TrackingProvider.swift
│       │       └── CrashlyticsProvider.swift
│       ├── Providers/
│       │   ├── AppFlyers/
│       │   │   └── AppFlyersProvider.swift
│       │   └── Firebase/
│       │       ├── FirebaseAnalyticsProvider.swift
│       │       └── FirebaseCrashlyticsProvider.swift
│       └── PublicProtocol/
│           ├── Protocol/
│           │   └── Tracking/
│           │       ├── TrackingManager.swift
│           │       └── DefaultTrackingManager.swift
│           ├── Model+Output/
│           │   ├── TrackingEvent.swift
│           │   └── TrackingError.swift
│           └── Protocol/
│               └── DI/
│                   └── TrackingServiceProvider.swift
└── Package.swift
```

## Extending the SDK

To add a new tracking provider:

1. Create a new class conforming to `TrackingProvider`:
```swift
public final class NewProvider: TrackingProvider {
    // Implement protocol methods
}
```

2. Add it to the builder:
```swift
let provider = NewProvider(appID: "id", devKey: "key")
let service = TrackingServiceProvider.Builder()
    .addTrackingProvider(provider)
    .build()
```

## License

[Your License Here]


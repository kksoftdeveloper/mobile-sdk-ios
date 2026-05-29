//
//  TrackingServiceProvider.swift
//  TrackingSDK
//
//  Created on 11/4/25.
//

import Foundation

/// Service provider for TrackingSDK
/// Provides a convenient way to configure and access tracking services
public final class TrackingServiceProvider {
    
    // MARK: - Properties
    
    public let trackingManager: TrackingManager
    
    // MARK: - Initialization
    
    private init(builder: Builder) {
        // Build tracking manager with configured providers
        let managerBuilder = DefaultTrackingManager.Builder()
        
        // Add tracking providers
        for provider in builder.trackingProviders {
            managerBuilder.addTrackingProvider(provider)
        }
        
        // Set crashlytics provider if provided
        if let crashlyticsProvider = builder.crashlyticsProvider {
            managerBuilder.setCrashlyticsProvider(crashlyticsProvider)
        }
        
        self.trackingManager = managerBuilder.build()
    }
    
    // MARK: - Builder
    
    public final class Builder {
        var trackingProviders: [TrackingProvider] = []
        var crashlyticsProvider: CrashlyticsProvider?
        
        // AppFlyers configuration
        var appFlyersAppID: String?
        var appFlyersDevKey: String?
        var enableAppFlyers: Bool = false
        
        // Firebase configuration (for future use)
        var firebaseAppID: String?
        var firebaseDevKey: String?
        var enableFirebaseAnalytics: Bool = false
        var isFirebaseCrashlyticsEnabled: Bool = false
        
        // Adjust configuration
        var adjustAppID: String?
        var adjustAppToken: String?
        var enableAdjust: Bool = false
        
        public init() {}
        
        // MARK: - AppFlyers Configuration
        
        /// Enable and configure AppFlyers
        /// - Parameters:
        ///   - appID: AppFlyers App ID
        ///   - devKey: AppFlyers Developer Key
        public func enableAppFlyers(appID: String, devKey: String) -> Builder {
            self.appFlyersAppID = appID
            self.appFlyersDevKey = devKey
            self.enableAppFlyers = true
            return self
        }
        
        // MARK: - Firebase Configuration (for future use)
        
        /// Enable and configure Firebase Analytics
        /// - Parameters:
        ///   - appID: Firebase App ID
        ///   - devKey: Firebase configuration key (optional)
        public func enableFirebaseAnalytics(appID: String, devKey: String? = nil) -> Builder {
            self.firebaseAppID = appID
            self.firebaseDevKey = devKey
            self.enableFirebaseAnalytics = true
            return self
        }
        
        /// Enable Firebase Crashlytics
        public func enableFirebaseCrashlytics() -> Builder {
            self.isFirebaseCrashlyticsEnabled = true
            return self
        }
        
        // MARK: - Adjust Configuration
        
        /// Enable and configure Adjust
        /// - Parameters:
        ///   - appID: Adjust App ID
        ///   - appToken: Adjust App Token (devKey)
        public func enableAdjust(appID: String, appToken: String) -> Builder {
            self.adjustAppID = appID
            self.adjustAppToken = appToken
            self.enableAdjust = true
            return self
        }
        
        // MARK: - Custom Providers
        
        /// Add a custom tracking provider
        public func addTrackingProvider(_ provider: TrackingProvider) -> Builder {
            trackingProviders.append(provider)
            return self
        }
        
        /// Set a custom crashlytics provider
        public func setCrashlyticsProvider(_ provider: CrashlyticsProvider) -> Builder {
            self.crashlyticsProvider = provider
            return self
        }
        
        // MARK: - Build
        
        /// Build the TrackingServiceProvider
        public func build() -> TrackingServiceProvider {
            // Create AppFlyers provider if enabled
            if enableAppFlyers, let appID = appFlyersAppID, let devKey = appFlyersDevKey {
                let appFlyersProvider = AppFlyersProvider(appID: appID, devKey: devKey)
                trackingProviders.append(appFlyersProvider)
            }
            
            // Create Firebase Analytics provider if enabled (placeholder for now)
            if enableFirebaseAnalytics, let appID = firebaseAppID {
                let firebaseProvider = FirebaseAnalyticsProvider(appID: appID, devKey: firebaseDevKey ?? "")
                trackingProviders.append(firebaseProvider)
            }
            
            // Create Firebase Crashlytics provider if enabled (placeholder for now)
            if isFirebaseCrashlyticsEnabled {
                if crashlyticsProvider == nil {
                    crashlyticsProvider = FirebaseCrashlyticsProvider()
                }
            }
            
            // Create Adjust provider if enabled
            if enableAdjust, let appID = adjustAppID, let appToken = adjustAppToken {
                let adjustProvider = AdjustTrackingProvider(appID: appID, devKey: appToken)
                trackingProviders.append(adjustProvider)
            }
            
            return TrackingServiceProvider(builder: self)
        }
    }
}


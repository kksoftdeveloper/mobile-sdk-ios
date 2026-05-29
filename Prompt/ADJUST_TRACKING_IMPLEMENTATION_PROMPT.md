# Adjust Tracking Implementation Prompt

## Overview

This document describes the requirement and implementation pattern for integrating Adjust tracking SDK alongside existing AppsFlyer tracking. The implementation should follow the same pattern as AppsFlyer but with `adj_` prefix for all event names and properties.

## Requirements

1. **Add Adjust SDK** to the project alongside AppsFlyer
2. **Prefix Convention**: All event names and properties should use `adj_` prefix (e.g., `adj_play_game`, `adj_uid`, `adj_character_id`)
3. **Event Parity**: All Adjust events should mirror AppsFlyer events with the `adj_` prefix
4. **Parallel Tracking**: Events should be sent to both AppsFlyer and Adjust simultaneously
5. **ID Retrieval**: Provide functionality to retrieve and display Adjust ID for testing purposes

## Implementation Pattern

### 1. Provider Architecture

Follow the same provider pattern used for AppsFlyer and Firebase:
- Create an `AdjustTrackingProvider` class that implements the `TrackingProvider` interface
- The provider should initialize Adjust SDK with app token
- All events should use `adj_` prefix for names and properties

### 2. Event Naming Convention

For each AppsFlyer event, create a corresponding Adjust event:

| AppsFlyer Event | Adjust Event |
|----------------|--------------|
| `af_play_game` | `adj_play_game` |
| `af_tutorial_completed_s1` | `adj_tutorial_completed_s1` |
| `af_lev_level_50` | `adj_lev_level_50` |
| `af_vip_level_10` | `adj_vip_level_10` |
| `af_online_30mins` | `adj_online_30mins` |
| `af_open_login_form` | `adj_open_login_form` |
| `af_login` | `adj_login` |
| `af_login_fail` | `adj_login_fail` |
| `af_registration` | `adj_registration` |
| `af_retention_d1` | `adj_retention_d1` |
| `af_start_iap` | `adj_start_iap` |
| `af_pay_success` | `adj_pay_success` |
| `af_pay_notyet_success` | `adj_pay_notyet_success` |

### 3. Property Naming Convention

For each AppsFlyer property, create a corresponding Adjust property:

| AppsFlyer Property | Adjust Property |
|-------------------|-----------------|
| `af_uid` | `adj_uid` |
| `af_character_id` | `adj_character_id` |
| `af_character_name` | `adj_character_name` |
| `af_server_id` | `adj_server_id` |
| `af_server_name` | `adj_server_name` |
| `af_mobile_carrier` | `adj_mobile_carrier` |
| `af_login_method` | `adj_login_method` |
| `af_login_fail_reason` | `adj_login_fail_reason` |
| `af_signup_method` | `adj_signup_method` |
| `af_retention_days` | `adj_retention_days` |
| `af_package_id` | `adj_package_id` |
| `af_order_id` | `adj_order_id` |
| `af_revenue` | `adj_revenue` |
| `af_currency` | `adj_currency` |
| `af_order_status` | `adj_order_status` |
| `af_level` | `adj_level` |

## Events to Implement

### In-Game Tracking Events (GameTracking)

1. **logPlayGame**
   - Event: `adj_play_game`
   - Properties: `adj_uid`, `adj_character_id`, `adj_character_name`, `adj_server_id`, `adj_server_name`, `adj_mobile_carrier`

2. **logTutorialCompletedS1**
   - Event: `adj_tutorial_completed_s1`
   - Properties: `adj_uid`, `adj_character_id`, `adj_character_name`, `adj_server_id`, `adj_server_name`, `adj_mobile_carrier`

3. **logLevelUp**
   - Event: `adj_lev_{level}` (e.g., `adj_lev_level_50`)
   - Properties: `adj_uid`, `adj_character_id`, `adj_character_name`, `adj_server_id`, `adj_server_name`, `adj_mobile_carrier`

4. **logVIPLevel**
   - Event: `adj_vip_level_{level}` (e.g., `adj_vip_level_10`)
   - Properties: `adj_uid`, `adj_character_id`, `adj_character_name`, `adj_server_id`, `adj_server_name`, `adj_mobile_carrier`, `adj_level`

5. **logOnlineTime**
   - Event: `adj_online_{minutes}mins` (e.g., `adj_online_30mins`)
   - Properties: `adj_uid`, `adj_character_id`, `adj_character_name`, `adj_level`, `adj_server_id`, `adj_server_name`, `adj_mobile_carrier`

### Authentication Tracking Events (AuthTracking)

1. **logOpenLoginForm**
   - Event: `adj_open_login_form`
   - Properties: None (empty properties)

2. **logLoginSuccess**
   - Event: `adj_login`
   - Properties: `adj_login_method`, `adj_mobile_carrier`, `adj_uid`

3. **logLoginFailure**
   - Event: `adj_login_fail`
   - Properties: `adj_login_method`, `adj_login_fail_reason`

4. **logRegisterSuccess**
   - Event: `adj_registration`
   - Properties: `adj_signup_method`, `adj_mobile_carrier`, `adj_uid`

5. **logRetentionD1** (handleRetentionD1IfNeeded)
   - Event: `adj_retention_d1`
   - Properties: `adj_uid`, `adj_retention_days`, `adj_mobile_carrier`

### Payment Tracking Events (PaymentTracking)

1. **logIapStart**
   - Event: `adj_start_iap`
   - Properties: `adj_uid`, `adj_character_id`, `adj_server_id`, `adj_server_name`, `adj_mobile_carrier`

2. **logIapSuccess**
   - Event: `adj_pay_success`
   - Properties: `adj_package_id`, `adj_order_id`, `adj_mobile_carrier`, `adj_character_id`, `adj_server_id`, `adj_server_name`, `adj_revenue` (optional), `adj_currency` (optional), `adj_uid`

3. **logIapFailure**
   - Event: `adj_pay_notyet_success`
   - Properties: `adj_package_id`, `adj_order_status`, `adj_mobile_carrier`, `adj_character_id`, `adj_server_id`, `adj_server_name`, `adj_currency` (optional), `adj_uid`

## Implementation Steps

### Step 1: Add Adjust SDK Dependency

Add the Adjust SDK to your project dependencies (CocoaPods/SPM/Manual):

**CocoaPods:**
```ruby
pod 'Adjust'
```

**Swift Package Manager:**
Add package: `https://github.com/adjust/ios_sdk`

### Step 2: Create AdjustTrackingProvider

Create a provider class that:
- Implements the same `TrackingProvider` interface/protocol as AppsFlyer
- Initializes Adjust SDK with app token
- Implements all tracking methods with `adj_` prefix

### Step 3: Initialize Adjust SDK

In your tracking initialization code:
- Add `AdjustTrackingProvider` to the list of providers
- Pass the Adjust app token during initialization
- Enable Adjust alongside AppsFlyer and Firebase

### Step 4: Update All Tracking Events

For each tracking call, add Adjust override with `adj_` prefix:
- In `GameTracking`: Add Adjust overrides for all 5 in-game events
- In `AuthTracking`: Add Adjust overrides for all 5 auth events
- In `PaymentTracking`: Add Adjust overrides for all 3 payment events

### Step 5: Add ID Retrieval Functionality

Implement methods to retrieve Adjust ID:
- Create `getAdjustId()` method that uses Adjust SDK's callback-based API
- Add functionality to display Adjust ID in testing/debug dialog
- Add copy-to-clipboard functionality for testing purposes

### Step 6: Update Debug Dialog

Update the debug/testing dialog (similar to AppsFlyerUidDialog):
- Display both AppsFlyer ID and Adjust ID
- Add individual copy buttons for each ID
- Show appropriate messages when IDs are not available

## Testing Requirements

1. **Verify all events are being sent** with correct `adj_` prefix
2. **Verify all properties** have `adj_` prefix
3. **Test ID retrieval** - Ensure Adjust ID can be retrieved and displayed
4. **Test copy functionality** - Verify IDs can be copied to clipboard
5. **Test event parity** - Ensure all AppsFlyer events have corresponding Adjust events

## Notes for iOS Implementation

### Adjust SDK Initialization (iOS/Swift)

```swift
import Adjust

let adjustConfig = ADJConfig(
    appToken: "YOUR_APP_TOKEN",
    environment: ADJEnvironmentProduction
)
adjustConfig?.logLevel = ADJLogLevelVerbose
Adjust.appDidLaunch(adjustConfig)
```

### Adjust Event Tracking (iOS/Swift)

```swift
let event = ADJEvent(eventToken: "adj_play_game")
event?.addCallbackParameter("adj_uid", value: uid)
event?.addCallbackParameter("adj_character_id", value: characterId)
Adjust.trackEvent(event)
```

### Adjust ID Retrieval (iOS/Swift)

```swift
Adjust.adid() { adid in
    // Use the adid here
    print("Adjust ID: \(adid ?? "nil")")
}
```

## Configuration

### Required Parameters

- **Adjust App Token**: Should be passed during SDK initialization (similar to AppsFlyer Dev Key)
- **Environment**: Use production environment by default

### Optional Settings

- **Log Level**: Set to verbose for debugging
- **Background Tracking**: Enable if needed

## Success Criteria

1. ✅ All 13 tracking events have Adjust equivalents with `adj_` prefix
2. ✅ All event properties have `adj_` prefix
3. ✅ Adjust SDK initializes correctly alongside AppsFlyer
4. ✅ Adjust ID can be retrieved and displayed in debug dialog
5. ✅ Copy functionality works for both AppsFlyer ID and Adjust ID
6. ✅ Events are sent to Adjust in parallel with AppsFlyer
7. ✅ No breaking changes to existing AppsFlyer/Firebase tracking

## Reference: Android Implementation

The Android implementation serves as a reference for:
- Provider pattern structure
- Event naming conventions
- Property mapping
- Initialization flow
- ID retrieval methods
- Dialog UI structure

Key files to reference:
- `AdjustTrackingProvider.kt`
- `GameTracking.kt`
- `AuthTracking.kt`
- `PaymentTracking.kt`
- `AppsFlyerUidDialog` (now displays both IDs)

## Additional Resources

- [Adjust iOS SDK Documentation](https://help.adjust.com/en/sdk/ios)
- [Adjust Event Tracking Guide](https://help.adjust.com/en/event-tracking)
- Existing AppsFlyer implementation in the codebase

---

**Last Updated**: After Android implementation completion
**Platform**: iOS (to be implemented)
**Pattern**: Follow Android implementation pattern with iOS-specific adjustments

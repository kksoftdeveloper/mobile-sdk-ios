# Unity iOS Example

## Environment Configuration

The project supports two environments: `staging` and `production`.

| Environment | Scheme | Build configuration | Configuration file | Bundle ID |
| --- | --- | --- | --- | --- |
| Staging | `Unity-iPhone-Staging` | `Debug-Staging` / `Release-Staging` | `Configs/Staging.xcconfig` | `com.kksoft.vn.ts3.staging` |
| Production | `Unity-iPhone` | `Debug-Production` / `Release-Production` | `Configs/Production.xcconfig` | `com.kksoft.vn.ts3` |

### Run staging

1. Open `Unity-iPhone.xcodeproj`.
2. Select the `Unity-iPhone-Staging` scheme.
3. Verify the values in `Configs/Staging.xcconfig`.
4. Build and run the app.

### Run production

1. Open `Unity-iPhone.xcodeproj`.
2. Select the `Unity-iPhone` scheme.
3. Verify the values in `Configs/Production.xcconfig`.
4. Archive or build the app.

`APP_ENV` is passed to `Info.plist` and used to initialize `AuthSDK` with the correct environment:

```text
APP_ENV=staging
APP_ENV=production
```

### Firebase

Each environment uses a separate Firebase configuration file:

| Environment | Firebase plist |
| --- | --- |
| Staging | `firebase/GoogleService-Info-Staging.plist` |
| Production | `firebase/GoogleService-Info-Production.plist` |

When changing the Firebase project, update the plist file and the `FirebaseAppID` value in the corresponding `.xcconfig` file.

## TikTok Configuration

TikTok App Events is initialized through `TrackingSDK` in `Classes/AuthWrapper/KKSoftPrxoy.swift`.

Add the TikTok credentials to the `.xcconfig` file for each environment:

```text
TiktokAppID=<tiktok-app-id>
TiktokAccessToken=<tiktok-events-manager-access-token>
```

Example:

```text
# Configs/Staging.xcconfig
TiktokAppID=<staging-tiktok-app-id>
TiktokAccessToken=<staging-access-token>

# Configs/Production.xcconfig
TiktokAppID=<production-tiktok-app-id>
TiktokAccessToken=<production-access-token>
```

These values are passed to `Info.plist`, then provided to:

```swift
.enableTikTok(
    accessToken: Bundle.main.infoDictionary?["TiktokAccessToken"] as? String ?? "",
    appID: Bundle.main.bundleIdentifier ?? "com.kksoft.vn.ts3.staging",
    tiktokAppID: Bundle.main.infoDictionary?["TiktokAppID"] as? String ?? ""
)
```

`appID` is the iOS bundle ID for the selected environment. `TiktokAppID` is the TikTok application ID. `TiktokAccessToken` is the access token created in TikTok Events Manager.

Do not commit the production access token if the repository can be accessed outside the team. For CI builds, inject the token into the `.xcconfig` file during the build process.

## Pre-release Checklist

1. Select the correct scheme.
2. Verify `APP_ENV`, `APP_BUNDLE_ID`, and `APP_DISPLAY_NAME`.
3. Verify the Firebase plist and `FirebaseAppID` for the selected environment.
4. Verify `TiktokAppID` and `TiktokAccessToken`.
5. Build the app and check for the `KKSOFT Proxy TrackingSDK Initialized` log message.

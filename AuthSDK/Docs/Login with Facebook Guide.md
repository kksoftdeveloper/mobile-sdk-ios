# Login with Facebook integration Guide for App

Reference link: 
- [Facebook official document](https://developers.facebook.com/docs/facebook-login/ios) 
### 1. Necessary data which received from Auth SDK team

- Facebook app ID: `APP-ID`
- Facebook display name: `DISPLAY-NAME`
- Facebook client token: `CLIENT-TOKEN`

### 2. Info.plist file
Right-click `Info.plist` and choose Open As ▸ Source Code

Copy and paste the following XML snippet into the body of your file (`<dict>...</dict>`)
```
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fbAPP-ID</string>
        </array>
    </dict>
</array>
<key>FacebookAppID</key>
<string>APP-ID</string>
<key>FacebookClientToken</key>
<string>CLIENT-TOKEN</string>
<key>FacebookDisplayName</key>
<string>DISPLAY-NAME</string>
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
</array>
```

Replace corresponding data received from [Auth SDK team](#1-necessary-data-which-received-from-auth-sdk-team)

### 3. AppDelegate.swift file
if your project using SwiftUI. Create `AppDelegate.swift` file then add this line into `<ProjectName>App.swift` file:

`@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate`

Example:
```
import SwiftUI

@main
struct AuthSDKExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
```

In `AppDelegate.swift` file, add:

```
import FacebookCore
```

Inside function `AppDelegate.application(_:didFinishLaunchingWithOptions:)` add this before line `return true`:
```
ApplicationDelegate.shared.application(
    application,
    didFinishLaunchingWithOptions: launchOptions
)
```

Inside function `AppDelegate.application(_:open:options:)` add this:
```
ApplicationDelegate.shared.application(
    app,
    open: url,
    sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
    annotation: options[UIApplication.OpenURLOptionsKey.annotation]
)
```

The final version example:
```
import UIKit
import FacebookCore

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
```
### 4. SceneDelegate.swift file (optional)

```
import FacebookCore

...

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else {
        return
    }

    ApplicationDelegate.shared.application(
        UIApplication.shared,
        open: url,
        sourceApplication: nil,
        annotation: [UIApplication.OpenURLOptionsKey.annotation]
    )
}
```

### 5. Call login with Facebook from AuthSDK

In your project, 
Add Login with Facebook button as you like, at the action when user touch inside the button, call method `AuthManager.loginWithSocial(provider:)` with provider is `AuthProviderTypeParameter.facebook`

Follow **AuthSDKExample** project for more detail
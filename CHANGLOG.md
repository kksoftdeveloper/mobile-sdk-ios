## 📦 Changelog

### [1.0.0] - 2026-06-01
#### Added
- IOne Environment Configuration – Example
- Integrate TikTok Tracking

### [1.0.0] - 2026-05-29
#### Added
- Handle staging and production
Use `setEnvironment()` to configure the SDK environment.

* Staging

```swift
AuthServiceProvider.Builder()
    .setEnvironment(Environment.staging)
    .build()
```

* Production

```swift
AuthServiceProvider.Builder()
    .setEnvironment(Environment.production)
    .build()
```

### [1.0.0] - 2025-09-03
#### Added
- Additorium API `authManager.getGameId()`

#### Changed
- Modification `initSDK` method of `AuthManager`: must include serverId as integer `serverId`
```Swift
authManager.initSDK(
    packageName: Bundle.main.bundleIdentifier ?? "com.i.one.tsvn",
    appVersion: Bundle.main.infoDictionary? [ "CFBundleShortVersionString" ] as? String ?? "1.0.0",
    serverId: serverId
)
```

### [1.0.0] - 2025-09-30
#### Added
- Additorium Notification Server Maintaince 
<img src="Screenshots/server-maintaince.jpeg" alt="Intro" width="150"/>

- The declaration of MyAppController.h
```Obj-C
#ifdef __cplusplus
extern "C" {
#endif

void startSDK(id<AuthResultDelegate> delegate);

void KKSOFT_Initialize(UIViewController *unityVC, OnCallback onCallback );

void KKSOFT_Auth();

void KKSOFT_TokenExpiration();

/**
 * New function here is for handling serverId, that is given from game-client side, being not valid.
*/
void KKSOFT_ServerMaintainance();

#ifdef __cplusplus
}
#endif
```

- The Implementation of MyAppController.h
```Obj-C
void KKSOFT_ServerMaintainance() {
    NSLog(@"KKSOFT - Server Maintainance");
    [g_proxy showServerMaintaince];
}

// Handle In-app notification whenever app/game is active
[[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handleServerMaintainance:)
                                                name:@"KKSOFT.ServerMaintainance"
                                            object:nil];

- (void)handleServerMaintainance:(NSNotification *)note
{
    NSLog(@"[MyAppController] Received SERVER MAINTAINANCE notification: %@", note.userInfo);

    dispatch_async(dispatch_get_main_queue(), ^{
        KKSOFT_ServerMaintainance();
    });
}

// Remove In-app notification whenever app/game is gone down
[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"KKSOFT.ServerMaintainance"
                                                  object:nil];
```

- The implementation of KKSoftProxy
```Swift
@MainActor @objc public func showServerMaintaince() {
    let view = ServerMaintenanceView(
        phoneNumber: "+84398686854",
        fanpage: "https://www.facebook.com/profile.php?id=61574162151534"
    ) { _,_ in
        
    }
//        let ret = session.toDictionnary(responseCode: "TOKEN_EXPIRED")
//        self.Callback ( jsonPairs : ret )
    
    let controller = UIHostingController(rootView: AnyView(view))
    controller.overrideUserInterfaceStyle = .light
    controller.modalPresentationStyle = .overFullScreen
    controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
    self.hostingController = controller
    self.presentingVC?.dismiss(animated: true, completion: {
        self.presentingVC?.present(controller, animated: false, completion: nil)
    })
}
```

### [1.0.0] - 2025-10-17
#### Change
Change serverId from Int to String
```swift
let view = WelcomeView(
            ...,
            serverId: "IOS1",
            ...
)

authManager.initSDK(
            packageName: Bundle.main.bundleIdentifier ?? "com.i.one.tsvn",
            appVersion: Bundle.main.infoDictionary? [ "CFBundleShortVersionString" ] as? String ?? "1.0.0",
            serverId: serverId
        )
```

### [1.0.0] - 2025-10-20
NOTE:
AUTHSDK:
New update Auth:
- server handling:
+ game/app must give serverId as string to SDK.

- facebook login:
+ JWT token for ios login via facebook and ios link account via facebook.
+ Login via facebook and link account via facebook same as it is. NO CHANGE.

### [1.0.0] - 2025-11-05
NOTE:

New update Auth:
In KKSoftProxy.swift, function named self.showForceUpdateView() has to execute on main thread.
```swift
// Line 109 - 111
DispatchQueue.main.async {
    self.showForceUpdateView()
}
```

In this class, adding one more line `.receive(on: DispatchQueue.main)`, seeing it at line 117
```swift
authManager.initSDK(
        packageName: Bundle.main.bundleIdentifier ?? "com.i.one.tsvn",
        appVersion: Bundle.main.infoDictionary? [ "CFBundleShortVersionString" ] as? String ?? "1.0.0",
        serverId: serverId
    )
    .receive(on: DispatchQueue.main) // line 101
    .flatMap { [weak self] gameInfo -> AnyPublisher<AuthSessionResponse, Error> in
        ....
        return self.authManager.getAuthSesssion()
    }
    .receive(on: DispatchQueue.main) // line 117
    .sink(...)
        
```

Add new files: AuthSessionOutputBridge.swift and Unity-iPhone-Bridging-Header.h
The class is used for transform session-info (access-token, refresh-token and game-uid) whenever refreshing being executed to obj-c dictionary

**IMPORTANCE
MyAppController.m
Add one more In-App notification listener: ```KKSOFT.RefreshedToken``` 
```obj-c
// Handle In-app notification
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(handleRefreshedToken:)
                                             name:@"KKSOFT.RefreshedToken"
                                            object:nil];
```

That notification catchs up refreshing session-info (access-token, refresh-token, and game-uid)

The below demonstrates how to handle notification session object, then parsing. Using parsed data saves into keychain if needed.
```obj-c
// Notification Callback
- (void)handleRefreshedToken:(NSNotification *)note
{
    NSLog(@"[MyAppController] ✅ Received refreshed token notification");
    NSLog(@"[MyAppController] Notification name: %@", note.name);
    NSLog(@"[MyAppController] Notification object: %@", note.object);
    NSLog(@"[MyAppController] Notification userInfo: %@", note.userInfo);
    
    // Extract AuthSessionOutput from notification object
    // The object is a Swift struct AuthSessionOutput, convert it to NSDictionary
    NSDictionary *authSessionDict = [AuthSessionOutputBridge extractFromNotification:note];
    
    if (authSessionDict != nil) {
        NSLog(@"[MyAppController] Extracted auth session: %@", authSessionDict);
        
        // Ensure we're on the main thread for UI/keychain operations
        dispatch_async(dispatch_get_main_queue(), ^{
            // Extract values safely with nil checks
            id accessTokenObj = authSessionDict[@"accessToken"];
            id gameUIDObj = authSessionDict[@"gameUID"];  // Note: Swift uses "gameUID" key
            id refreshTokenObj = authSessionDict[@"refreshToken"];
            
            NSString *accessToken = nil;
            NSString *gameUID = nil;
            NSString *refreshToken = nil;
            
            // Safely convert to NSString
            if ([accessTokenObj isKindOfClass:[NSString class]]) {
                accessToken = (NSString *)accessTokenObj;
            } else if ([accessTokenObj isKindOfClass:[NSNumber class]]) {
                accessToken = [(NSNumber *)accessTokenObj stringValue];
            }
            
            if ([gameUIDObj isKindOfClass:[NSString class]]) {
                gameUID = (NSString *)gameUIDObj;
            } else if ([gameUIDObj isKindOfClass:[NSNumber class]]) {
                gameUID = [(NSNumber *)gameUIDObj stringValue];
            }
            
            if ([refreshTokenObj isKindOfClass:[NSString class]]) {
                refreshToken = (NSString *)refreshTokenObj;
            } else if ([refreshTokenObj isKindOfClass:[NSNumber class]]) {
                refreshToken = [(NSNumber *)refreshTokenObj stringValue];
            }
            
            NSLog(@"[MyAppController] Access Token: %@", accessToken);
            NSLog(@"[MyAppController] Game UID: %@", gameUID);
            NSLog(@"[MyAppController] Refresh Token: %@", refreshToken);
            
            // Save to keychain
            if (accessToken && refreshToken && gameUID) {
                [[KeychainManagerObjCBridge shared] saveAuthSessionDict:authSessionDict];
                NSLog(@"[MyAppController] ✅ Refreshed token data saved successfully.");
                
                // Call your delegate method if needed
                // [self didRefreshedTokenWithData:authSessionDict];
            } else {
                NSLog(@"[MyAppController] ⚠️ Missing required values - accessToken: %@, refreshToken: %@, gameUID: %@", 
                      accessToken != nil ? @"present" : @"nil",
                      refreshToken != nil ? @"present" : @"nil",
                      gameUID != nil ? @"present" : @"nil");
            }
        });
    } else {
        NSLog(@"[MyAppController] Failed to extract AuthSessionOutput from notification");
        
        // Fallback: try to get from userInfo if it was posted there
        if (note.userInfo != nil && note.userInfo.count > 0) {
            NSDictionary *dict = note.userInfo;
            NSLog(@"[MyAppController] Using userInfo instead: %@", dict);
            [[KeychainManagerObjCBridge shared] saveAuthSessionDict:dict];
        }
    }
}
```

PAYMENT:
New Update in PaymentSDK

Add one more param `refresh-token` in PackageListView, seeing KKSoftPrxoy.swift file
```swift
let view = PackageListView(
            onCloseClick: {
                self.Callback(jsonPairs: "IAP".toDictionnary())
                self.getRootViewController()?.dismiss(animated: true, completion: {
                    self.showMenu(session: session)
                })
            },
            packageName: Bundle.main.bundleIdentifier ?? "com.i.one.tsvn",
            gameId: authManager.getGameId() ?? 1,
            deviceId: authManager.getDeviceID(),
            osVersion: "15.0",
            accessToken: session.accessToken,
            refreshToken: session.refreshToken, // line 395
            phoneNumber: authManager.getPhoneNumber(),
            appVersion: Bundle.main.infoDictionary? [ "CFBundleShortVersionString" ] as? String ?? "1.0.0",
            serverId: "\(serverId)",
            gameUUID: "\(session.gameUUID)",
            isGuestUser: authManager.isGuestUser()
        )
```

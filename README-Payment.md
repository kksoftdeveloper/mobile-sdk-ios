1. Show list of IAP items.
To present a list of IAP items, we not only give game-id, device-id, access-token, game-uuid and phone number getting from auth-manager but also server-id providing by game-clients itself. 

```Swift
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
    phoneNumber: authManager.getPhoneNumber(),
    appVersion: Bundle.main.infoDictionary? [ "CFBundleShortVersionString" ] as? String ?? "1.0.0",
    serverId: "\(serverId)",
    gameUUID: "\(session.gameUUID)",
    isGuestUser: authManager.isGuestUser()
)
let controller = UIHostingController(rootView: AnyView(view))
controller.overrideUserInterfaceStyle = .light
controller.modalPresentationStyle = .overCurrentContext
controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
self.hostingController = controller
self.presentingVC?.present(controller, animated: false, completion: nil)
```

2. Implementation of In-app Notification.
To handle the IAP purchase results, please apply the four methods in main-app-controller.

```Obj-C
// Register in-app notification
- (void)applicationDidBecomeActive:(UIApplication*)application
{
    // Call Unity's logic first
    [super applicationDidBecomeActive:application];
    
//
    // Handle In-app notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUnauthenticated:)
                                                 name:@"KKSOFT.UnauthenticatedToken" // [NotificationKeys UNAUTHENTICATED_TOKEN_KEY]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTokenExpired:)
                                                 name:@"KKSOFT.ExpirationToken"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleIAPSuccess:)
                                                 name:@"KKSOFT.IAP.Success"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleIAPFail:)
                                                 name:@"KKSOFT.IAP.FAIL"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleIAPInvalidSKU:)
                                                 name:@"KKSOFT.IAP.InvalidSKU"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleIAPUserCancel:)
                                                 name:@"KKSOFT.IAP.UserCancel"
                                               object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_callback) {
            NSDictionary *data = @{
                @"event": @"appDidBecomeActive",
                @"platform": @"iOS",
                @"timestamp": @([[NSDate date] timeIntervalSince1970])
            };
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            g_callback([jsonString UTF8String]); // Call Unity callback
            
        }
        NSLog(@"KKSOFT Initialized from MyAppController");
        KKSOFT_Initialize(GetAppController().rootViewController, g_callback);
    });
}


// Implementation of purchase results and tokens exception
// Notification Callback
- (void)handleUnauthenticated:(NSNotification *)note
{
    NSLog(@"[MyAppController] Received UNAUTHENTICATED notification: %@", note.userInfo);

    dispatch_async(dispatch_get_main_queue(), ^{
        KKSOFT_Auth();
    });
}

// Notification Callback
- (void)handleTokenExpired:(NSNotification *)note
{
    NSLog(@"[MyAppController] Received TOKEN EXPIRED notification: %@", note.userInfo);

    dispatch_async(dispatch_get_main_queue(), ^{
        KKSOFT_TokenExpiration();
    });
}

- (void)handleIAPSuccess:(NSNotification *)data
{
    NSLog(@"[MyAppController] IAP Success: %@", data);
}

- (void)handleIAPFail:(NSNotification *)data
{
    NSLog(@"[MyAppController] IAP Fail: %@", data);
}

- (void)handleIAPUserCancel:(NSNotification *)data
{
    NSLog(@"[MyAppController] IAP User cancel: %@", data);
}

- (void)handleIAPInvalidSKU:(NSNotification *)data
{
    NSLog(@"[MyAppController] IAP Invalid SKU: %@,", data);
}

// Unregister in-app notification
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"KKSOFT.UnauthenticatedToken"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"KKSOFT.ExpirationToken"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"KKSOFT.IAP.Success"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"KKSOFT.IAP.FAIL"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"KKSOFT.IAP.InvalidSKU"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"KKSOFT.IAP.UserCancel"
                                                  object:nil];
}
```

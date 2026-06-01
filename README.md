# AuthSDK

# Unity-iOS SwiftUI AuthSDK Integration Guide

<img src="Screenshots/login-view.jpeg" alt="Intro" width="150"/>

## Changelog
Seeing at [CHANGELOG.md](./CHANGELOG.md)

## Table of Contents

1. [Preparation](#preparation)
2. [Add SDKs to Xcode Project](#add-sdks-to-xcode-project)
3. [Proxy](#proxy)
---

## 1. Preparation

1. Go to folder:  
   `UnityExample/iOS`
2. Open the Xcode project:  
   `Unity-iPhone`
3. In Xcode:  
   - Go to **File > Packages > Update to Latest Packages Version**

---

## 2. Add SDKs to Xcode Project

### Add AuthSDK Local Package

1. Open:  
   **Project Settings > Package Dependencies**
2. Click **Add Local**
3. Select folder:  
   `Packages/AuthSDK`
4. Click **Add Package**


---

## 3. Proxy
3.1. KKSoft Proxy.
The implementation of KKSoft at the end of the file. 

Here is an definition of call-back
```Swift
    static let ResponseCodes : [ String : Int ] = [
        "INITIALIZE" : 1,
        "AUTH" : 2,
        "LOGOUT" : 3,
        "UPDATE_GAME_SERVER" : 4,
        "DELETE_ACCOUNT" : 5,
        "REFRESH_TOKEN" : 6,
        "GET_LATEST_SESSION" : 7,
        "USER_BLOCKED" : 8,
        "FORCE_UPDATE" : 9,
        "TOKEN_EXPIRED" : 10,
    ]
    
    static let ResultCodes : [ String : Int ] = [
        "FAIL" : -1,
        "CANCEL" : 0,
        "SUCCESS" : 1
    ]
    
    func Callback ( jsonPairs : [ String : Any ] ) {
        NSLog ( "---- KKSOFT: proxy Callback" );
        
        do
        {
            let jsonData = try JSONSerialization.data (
                withJSONObject : jsonPairs,
                options : []
            )
            let finalJSON = String ( data : jsonData, encoding : .utf8 ) ?? ""
            
            print ( "Final JSON for callback: \( finalJSON )" )
            
            onCallback? ( finalJSON )
            
        } catch
        {
            print ( "Error serializing JSON: \( error )" )
        }
    }
```
3.2. Main View Controller.

Creation of a custom view controller that inherits from main view controller is to take an advantages of open-close concept. The inheritted view controller names MyAppController, for example.

```Obj-C
#import <UnityFramework/UnityFramework.h>
#import <UnityFramework/UnityAppController.h>
#import <MenuDialogViewController.h>

#ifndef MyAppController_h
#define MyAppController_h

@interface MyAppController : UnityAppController
typedef void ( * OnCallback ) ( const char* object );
@end

@end

#endif /* MyAppController_h */

#ifdef __cplusplus
extern "C" {
#endif

void KKSOFT_Initialize(UIViewController *unityVC, OnCallback onCallback );

void KKSOFT_Auth();

void KKSOFT_TokenExpiration();

#ifdef __cplusplus
}
#endif
```

In this class, It is clearly that, there are some extra functions having declaration such as initialize, auth & token expiration.

Initialize function is for initializing Auth SDK.
Auth function is for authenticating credentials.
Token-expiration is for catching up expired token error while playing or using game/app.

Because of this defination of custom view controller, there is an implementation of the given class.

```Obj-C
void KKSOFT_Initialize(UIViewController *unityViewController, OnCallback onCallBack) {
    NSLog(@"KKSOFT - Initialize");
    g_proxy = KKSOFTProxy.shared;
    [g_proxy Initialize:unityViewController:onCallBack];
}

void KKSOFT_Auth() {
    NSLog(@"KKSOFT - Auth");
    [g_proxy Auth];
}

void KKSOFT_TokenExpiration() {
    NSLog(@"KKSOFT - Token Expiration");
    [g_proxy showTokenExpiration];
}
```

As soon as the game/app becomes active, we are not only about to start auth sdk, but also register in-app notifications such as unauthentication token and expiration token notifying from Auth SDK.

```Obj-C
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
    
    // Handle In-app notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTokenExpired:)
                                                 name:@"KKSOFT.ExpirationToken" // [NotificationKeys EXPIRATION_TOKEN_KEY]
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
```

Further to this, configurating facebook info for login via facebook feature is a must.

```Obj-C
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [FontLoaderObjCBridge loadAllFonts];
    
    // Facebook SDK init
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    // Set Facebook settings
    [FBSDKSettings.sharedSettings setAppID:@"1161544315137705"];
    [FBSDKSettings.sharedSettings setClientToken:@"6a2631357b252d0ba6818832146a59dc"];
    FBSDKSettings.sharedSettings.autoLogAppEventsEnabled = NO;
    [FBSDKSettings.sharedSettings enableLoggingBehavior:FBSDKLoggingBehaviorDeveloperErrors];
    
    // Call super for Unity init
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// iOS 10+ method
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    // Handle Facebook SDK
    BOOL handledByFacebook = [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url options:options];
    // Handle Unity by calling super (parent logic)
    BOOL handledByUnity = [super application:app openURL:url options:options];
    
    // Return YES if either handler handled the URL
    return handledByFacebook || handledByUnity;
}
```

Loading font
Setup facebook app id and facebook app schema-url
```Obj-C
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [FontLoaderObjCBridge loadAllFonts];
    
    // Facebook SDK init
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    // Set Facebook settings
    [FBSDKSettings.sharedSettings setAppID:@"1161544315137705"];
    [FBSDKSettings.sharedSettings setClientToken:@"6a2631357b252d0ba6818832146a59dc"];
    FBSDKSettings.sharedSettings.autoLogAppEventsEnabled = NO;
    [FBSDKSettings.sharedSettings enableLoggingBehavior:FBSDKLoggingBehaviorDeveloperErrors];
    
    // Call super for Unity init
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
```

Info.plist setting
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.511211441022-p18sv5i70b87g3440kr2ld0bujg385rk</string>
            <string>fb1161544315137705</string>
        </array>
    </dict>
</array>
<key>FacebookAppID</key>
<string>1161544315137705</string>
<key>FacebookAutoLogAppEventsEnabled</key>
<true/>
<key>FacebookClientToken</key>
<string>6a2631357b252d0ba6818832146a59dc</string>
<key>FacebookDisplayName</key>
<string>SDKExample</string>
<key>GIDClientID</key>
<string>511211441022-p18sv5i70b87g3440kr2ld0bujg385rk.apps.googleusercontent.com</string>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fb-messenger-share-api</string>
    <string>fbauth2</string>
    <string>fbshareextension</string>
</array>
<key>NSUserTrackingUsageDescription</key>
<string>We use your data to provide personalized ads and improve your experience.</string>
```

- Environment Configuration

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

```Swift
import Foundation
import AuthSDK
import SwiftUI
import Combine
import PaymentSDK

@objc public class KKSOFTProxy : NSObject {
    static let ResponseCodes : [ String : Int ] = [
        "INITIALIZE" : 1,
        "AUTH" : 2,
        "LOGOUT" : 3,
        "UPDATE_GAME_SERVER" : 4,
        "DELETE_ACCOUNT" : 5,
        "REFRESH_TOKEN" : 6,
        "GET_LATEST_SESSION" : 7,
        "USER_BLOCKED" : 8,
        "FORCE_UPDATE" : 9,
        "TOKEN_EXPIRED" : 10,
    ]
    
    static let ResultCodes : [ String : Int ] = [
        "FAIL" : -1,
        "CANCEL" : 0,
        "SUCCESS" : 1
    ]
    
    func Callback ( jsonPairs : [ String : Any ] ) {
        NSLog ( "---- KKSOFT: proxy Callback" );
        
        do
        {
            let jsonData = try JSONSerialization.data (
                withJSONObject : jsonPairs,
                options : []
            )
            let finalJSON = String ( data : jsonData, encoding : .utf8 ) ?? ""
            
            print ( "Final JSON for callback: \( finalJSON )" )
            
            onCallback? ( finalJSON )
            
        } catch
        {
            print ( "Error serializing JSON: \( error )" )
        }
    }

    
    @MainActor @objc public static let shared = KKSOFTProxy()
    
    public typealias OnCallback = @convention(c) (UnsafePointer<CChar>?) -> Void
    private var onCallback: OnCallback?
    
    var authManager : AuthManager = AuthServiceProvider.Builder().setEnvironment(Environment.staging).build().authManager
    
    weak var hostingController : UIHostingController<AnyView>?
    @objc public var presentingVC: UIViewController?
    
    // Link Account pops up automatically
    private var autoLinkTimer: Timer?
    private var autoLinkPopupInterval: Int = 60 // Default, or change as needed
    private var autoLinkRemainingSeconds: Int = 60
    private var lastGuestToken: String?
    private var isAutoLinkDialogShowing: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
 
    @MainActor @objc public func Initialize (_ unityVC: UIViewController, _ onCallback : @escaping OnCallback )
    {
        NSLog ( "---- KKSOFT Proxy Initialize" )
        
        self.onCallback = onCallback
        self.presentingVC = unityVC
        
        authManager.initSDK(
            packageName: Bundle.main.bundleIdentifier ?? "com.i.one.tsvn",
            appVersion: Bundle.main.infoDictionary? [ "CFBundleShortVersionString" ] as? String ?? "1.0.0"
        )
        .receive(on: DispatchQueue.main)
        .flatMap { [weak self] gameInfo -> AnyPublisher<AuthSessionResponse, Error> in
            guard let self = self else { return Empty().eraseToAnyPublisher() }
            let versionInfo = gameInfo.versionInfo
            
            if versionInfo.forceUpdate {
                self.showForceUpdateView()
                return Empty().eraseToAnyPublisher()
            }
            let session = self.authManager.getAuthSesssion()
            return session
        }
        .sink(
            receiveCompletion: { completionStatus in
                NSLog ("---- KKSOFT Proxy Init completionStatus \(completionStatus)")
                if case .failure(let error) = completionStatus {
                    if (error is AuthErrorResponse && (error as? AuthErrorResponse)?.code == AuthErrorCodeResponse.Unauthorized) {
                        DispatchQueue.main.async {
                            self.Auth()
                        }
                    } else {
                        var jsonPairs : [ String : Any ]
                        jsonPairs = [ : ]
                        jsonPairs [ "ResponseCode" ] = KKSOFTProxy
                            .ResponseCodes [ "INITIALIZE" ]
                        jsonPairs [ "ResultCode" ] = KKSOFTProxy
                            .ResultCodes [ "FAIL" ]
                        
                        if error is AuthErrorResponse {
                            jsonPairs [ "Code" ] = (
                                error as? AuthErrorResponse
                            )?.code.id
                            jsonPairs [ "Message" ] = (
                                error as? AuthErrorResponse
                            )?.message
                        }
                        self.Callback ( jsonPairs : jsonPairs )
                        self.showMenu(session: nil)
                    }
                }
            },
            receiveValue: {  session in
                NSLog ( "---- KKSOFT Proxy Init receiveValue \(session)" )
                
                if session.loginReminderResponse?.isGuestUser == true {
                    self.startAutoLinkAccountLoop(
                        timeToRemindInSeconds: (
                            session.asDictionary()["loginAfterSeconds"] as? Int
                        ) ?? 60,
                        guestToken: session.accessToken
                    ) { result, error in };
                }
                
                if !session.accessToken.isEmpty {
                    if session.userBlocked == true {
                        self.showUserBlockedView(data: session)
                        
                    } else  if session.gameUUID == nil {
                        self.showGameServerView(data: session)
                    } else {
                        self.Callback (
                            jsonPairs : session.toDictionnary(responseCode: "INITIALIZE")
                        )
                        DispatchQueue.main.async {
                            self.showMenu(session: session)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.Auth()
                    }
                }
            }
        )
        .store(in: &cancellables)
    }
    
    
    @MainActor @objc public func Auth () {
        NSLog ( "---- KKSOFT Proxy Auth" )
        let view = WelcomeView (
            authManager : authManager,
            packageName : Bundle.main.bundleIdentifier ?? "com.i.one.tsvn",
            appVersionName : Bundle.main.infoDictionary? [ "CFBundleShortVersionString" ] as? String ?? "1.0.0",
            onSuccess: { data in
                NSLog ( "---- KKSOFT Proxy Auth onSuccess" )
//                guard let self = self else { return }
                self.Callback(
                    jsonPairs: data.toDictionnary(responseCode: "AUTH")
                )
                if data.userBlocked == true {
                    self.showUserBlockedView(data: data)
                    
                } else if data.gameUUID == nil {
                    self.showGameServerView(data: data)
                    
                } else {
                    self.getRootViewController()?.dismiss(animated: true, completion: {
                        self.showMenu(session: data)
                    })
                }
            },
            onRefreshedToken: { [weak self] data in
                NSLog ( "---- KKSOFT Proxy Auth onSuccess" )
                guard let self = self else { return }
                self.Callback(
                    jsonPairs: data.toDictionnary(responseCode: "REFRESH_TOKEN")
                )
                self.hostingController?.dismiss(animated: true, completion: nil)
            },
            onFailure: { [weak self] authErrorResponse in
                NSLog ( "---- KKSOFT Proxy Auth onFailure" )
                guard let self = self else { return }
                var jsonPairs = [String : Any]()
                jsonPairs [ "ResponseCode" ] = KKSOFTProxy.ResponseCodes [ "AUTH" ]
                jsonPairs [ "ResultCode" ] = KKSOFTProxy.ResultCodes [ "FAIL" ]
                jsonPairs [ "Message" ] = authErrorResponse.message
                jsonPairs [ "Code" ] = authErrorResponse.code.id
                self.Callback ( jsonPairs : jsonPairs )
                
                //                self.hostingController?.dismiss(
                //                    animated: true,
                //                    completion: {
                //                        self.showMenu(
                //                            session: nil,
                //                            error: authErrorResponse.message
                //                        )
                //                    })
            },
            onClose: {
                NSLog ( "---- KKSOFT Proxy Auth onClose" )
                self.Callback ( jsonPairs : "AUTH".toDictionnary() )
                self.hostingController?.dismiss(animated: true, completion: {
                    self.showMenu(session: nil)
                })
            }
        )
        
        let controller = UIHostingController(rootView: AnyView(view))
        controller.overrideUserInterfaceStyle = .light
        controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.hostingController = controller
        
        let nav = UINavigationController ( rootViewController : controller )
        nav.modalPresentationStyle = .overFullScreen
        
//        presentingVC?.present ( nav, animated : true, completion : nil )
        
        self.getRootViewController()?.present(nav, animated: true, completion: nil)
    }
    
    @MainActor public func showLogout(session: AuthSessionResponse?) {
        print("Show Logout View")
        let view = LogoutConfirmView(
            onClose: {
                "LOGOUT".toDictionnary()
                self.hostingController?.dismiss(animated: true, completion: {
                    self.showMenu(session: session)
                })
            },
            onConfirm: {
                print("Logout API")
                self.authManager.logout()
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: {  completionStatus in
                        
                            if case .failure(let error) = completionStatus {
                                var jsonPairs : [ String : Any ]
                                jsonPairs = [ : ]
                                jsonPairs [ "ResponseCode" ] = KKSOFTProxy
                                    .ResponseCodes [ "LOGOUT" ]
                                jsonPairs [ "ResultCode" ] = KKSOFTProxy
                                    .ResultCodes [ "FAIL" ]
                                
                                self.Callback ( jsonPairs : jsonPairs )
                                self.hostingController?
                                    .dismiss(
                                        animated: true,
                                        completion: {
                                            self.showMenu(
                                                session: session,
                                                error: "Log out failed."
                                            )
                                        })
                            }
                            
                        },
                        receiveValue: {  data in
                            
                            var jsonPairs : [ String : Any ]
                            jsonPairs = [ : ]
                            jsonPairs [ "ResponseCode" ] = KKSOFTProxy
                                .ResponseCodes [ "LOGOUT" ]
                            jsonPairs [ "ResultCode" ] = KKSOFTProxy
                                .ResultCodes [ "SUCCESS" ]
                            self.Callback (
                                jsonPairs : session?
                                    .toDictionnary(
                                        responseCode: "LOGOUT"
                                    ) ?? jsonPairs
                            )
                            
                            self.hostingController?
                                .dismiss(animated: true, completion: {
                                    self.showMenu(session: nil)
                                })
                        }
                    )
                    .store(in: &self.cancellables)
            }
        )
        let controller = UIHostingController(rootView: AnyView(view))
        controller.overrideUserInterfaceStyle = .light
        controller.modalPresentationStyle = .overFullScreen
        controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.hostingController = controller
        self.presentingVC?.present(controller, animated: false, completion: nil)
    }
    
    @MainActor public func showGameServerView(session: AuthSessionResponse?) {
        print("Show Game Server View")
        let view = GameServerView(
            authManager: self.authManager,
            isShownCloseButton: true,
            onClose: {
                let json = "UPDATE_GAME_SERVER".toDictionnary();
                self.Callback(jsonPairs: json)
                self.hostingController?.dismiss(animated: true, completion: {
                    self.showMenu(session: session)
                })
            },
            onUpdatedGameServer: { [weak self] selectedGameServerId, gameUUID in
                guard let self = self else { return }
                let json = session?.copy(
                    gameUUID: gameUUID, serverId: selectedGameServerId
                ).toDictionnary(responseCode: "UPDATE_GAME_SERVER")
                self.Callback(jsonPairs: json!)
                
                self.hostingController?.dismiss(animated: true, completion: {
                    self.showMenu(session: session)
                })
            }
        )
        let controller = UIHostingController(rootView: AnyView(view))
        controller.overrideUserInterfaceStyle = .light
        controller.modalPresentationStyle = .overFullScreen
        controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.hostingController = controller
        self.presentingVC?.present(controller, animated: false, completion: nil)
    }
    
    @MainActor public func showPackageItems(session: AuthSessionResponse) {
        print("Show Game Server View")
        //        let view = PackageListView(
        //            viewModel: <#T##PackageListViewModel#>, onCloseClick: <#T##() -> Void#>)(
        //            authManager: self.authManager,
        //            isShownCloseButton: true,
        //            onClose: {
        //                let json = "UPDATE_GAME_SERVER".toDictionnary();
        //                self.Callback(jsonPairs: json)
        //                self.hostingController?.dismiss(animated: true, completion: {
        //                    self.showMenu(session: session)
        //                })
        //            },
        //            onUpdatedGameServer: { [weak self] selectedGameServerId, gameUUID in
        //                guard let self = self else { return }
        //                let json = session?.copy(
        //                    gameUUID: gameUUID, serverId: selectedGameServerId
        //                ).toDictionnary(responseCode: "UPDATE_GAME_SERVER")
        //                self.Callback(jsonPairs: json!)
        //
        //                self.hostingController?.dismiss(animated: true, completion: {
        //                    self.showMenu(session: session)
        //                })
        //            }
        //        )
        let view = PackageListView(
            onCloseClick: {
                self.Callback(jsonPairs: "IAP".toDictionnary())
                self.getRootViewController()?.dismiss(animated: true, completion: {
                    self.showMenu(session: session)
                })
            },
            packageName: Bundle.main.bundleIdentifier ?? "com.i.one.tsvn",
            gameId: 1,
            deviceId: authManager.getDeviceID(),
            osVersion: "15.0",
            accessToken: session.accessToken,
            phoneNumber: authManager.getPhoneNumber(),
            appVersion: Bundle.main.infoDictionary? [ "CFBundleShortVersionString" ] as? String ?? "1.0.0",
            serverId: "\(session.serverId)",
            gameUUID: "\(session.gameUUID)"
        )
        let controller = UIHostingController(rootView: AnyView(view))
        controller.overrideUserInterfaceStyle = .light
        controller.modalPresentationStyle = .overCurrentContext
        controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.hostingController = controller
        self.presentingVC?.present(controller, animated: false, completion: nil)
    }
    
    @MainActor public func showDeactivateAccount(session: AuthSessionResponse?) {
        print("Show Deactivate Account View")
        let view = DeactivateAccountView(
            onClose: {
                self.Callback(jsonPairs: "DELETE_ACCOUNT".toDictionnary())
                self.hostingController?.dismiss(animated: true, completion: {
                    self.showMenu(session: session)
                })
            },
            onSuccess: {
                var jsonPairs : [ String : Any ]
                jsonPairs = [ : ]
                jsonPairs [ "ResponseCode" ] = KKSOFTProxy.ResponseCodes [ "DELETE_ACCOUNT" ]
                jsonPairs [ "ResultCode" ] = KKSOFTProxy.ResultCodes [ "SUCCESS" ]
                self.Callback(jsonPairs: jsonPairs)
                
                self.hostingController?.dismiss(animated: true, completion: {
                    self.showMenu(session: nil)
                })
            },
            onFailure: {
                var jsonPairs : [ String : Any ]
                jsonPairs = [ : ]
                jsonPairs [ "ResponseCode" ] = KKSOFTProxy.ResponseCodes [ "DELETE_ACCOUNT" ]
                jsonPairs [ "ResultCode" ] = KKSOFTProxy.ResultCodes [ "FAIL" ]
                self.Callback(jsonPairs: jsonPairs)
                
                self.hostingController?.dismiss(animated: true, completion: {
                    self.showMenu(session: session, error: "Delete account error")
                })
            },
            authManager: self.authManager,
        )
        let controller = UIHostingController(rootView: AnyView(view))
        controller.overrideUserInterfaceStyle = .light
        controller.modalPresentationStyle = .overCurrentContext
        controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.hostingController = controller
        self.presentingVC?.present(controller, animated: false, completion: nil)
    }
    
    public func refreshToken(session: AuthSessionResponse?) {
        self.authManager.refreshToken()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionStatus in
                    guard let self = self else { return }
                    if case .failure(let error) = completionStatus {
                        var jsonPairs = [String : Any]()
                        jsonPairs [ "ResponseCode" ] = KKSOFTProxy.ResponseCodes [ "REFRESH_TOKEN" ]
                        jsonPairs [ "ResultCode" ] = KKSOFTProxy.ResultCodes [ "FAIL" ]
                        
                        if error is AuthErrorResponse {
                            jsonPairs [ "Message" ] = (error as? AuthErrorResponse)?.message
                            jsonPairs [ "Code" ] = (error as? AuthErrorResponse)?.code.id
                        }
                        self.Callback(jsonPairs: jsonPairs)
                    }
                },
                receiveValue: { [weak self] data in
                    guard let self = self else { return }
                    let dict = data.toDictionnary(responseCode: "REFRESH_TOKEN")
                    self.Callback(jsonPairs: dict)
                }
            )
            .store(in: &cancellables)
    }
    
    @objc public func getLatestSession() {
        self.authManager.getAuthSesssion()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionStatus in
                    guard let self = self else { return }
                    if case .failure(let error) = completionStatus {
                        var jsonPairs = [String : Any]()
                        jsonPairs [ "ResponseCode" ] = KKSOFTProxy.ResponseCodes [ "GET_LATEST_SESSION" ]
                        jsonPairs [ "ResultCode" ] = KKSOFTProxy.ResultCodes [ "FAIL" ]
                        
                        if error is AuthErrorResponse {
                            jsonPairs [ "Message" ] = (error as? AuthErrorResponse)?.message
                            jsonPairs [ "Code" ] = (error as? AuthErrorResponse)?.code.id
                        }
                        self.Callback(jsonPairs: jsonPairs)
                    }
                },
                receiveValue: { [weak self] data in
                    guard let self = self else { return }
                    let dict = data.toDictionnary(responseCode: "GET_LATEST_SESSION")
                    self.Callback(jsonPairs: dict)
                }
            )
            .store(in: &cancellables)
    }
    
    @objc public func startAutoLinkAccountLoop(timeToRemindInSeconds: Int = 60, guestToken: String,
                                               _ completion: @escaping (NSDictionary?, NSError?) -> Void) {
        stopAutoLinkAccountLoop()
        autoLinkPopupInterval = timeToRemindInSeconds
        autoLinkRemainingSeconds = autoLinkPopupInterval
        lastGuestToken = guestToken
        autoLinkTimer = Timer
            .scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.isAutoLinkDialogShowing { return }
                if self.autoLinkRemainingSeconds > 0 {
                    self.autoLinkRemainingSeconds -= 1
                    print("⏳ Link popup in \(self.autoLinkRemainingSeconds)s")
                } else {
                    print("🔔 Showing LinkAccountView now")
                    self.isAutoLinkDialogShowing = true
                    Task { @MainActor in
                        // 👇 Add another guard here to guarantee `self` is not nil
                        //                     guard let self = self else { return }
                        print("Show Link Account View")
                        
                        var controller: UIHostingController<AnyView>? = nil
                        let view = LinkAccountView(
                            authManager: self.authManager,
                            // <- now safe!
                            guestToken: guestToken,
                            onSuccess: {  data in
                                
                                self.Callback(
                                    jsonPairs: data
                                        .toDictionnary(responseCode: "AUTH")
                                )
                                self.isAutoLinkDialogShowing = false
                                controller?
                                    .dismiss(animated: true, completion: nil)
                                self.stopAutoLinkAccountLoop()
                            },
                            onFailure: { [weak self] error in
                                guard let self = self else { return }
                                let nsError = NSError(
                                    domain: "com.i.auth",
                                    code: -1
                                )
                                self.isAutoLinkDialogShowing = false
                                controller?
                                    .dismiss(animated: true, completion: nil)
                                self.Callback(jsonPairs: error.toDictionary())
                            },
                            onClose: {
                                "AUTH".toDictionnary()
                                self.isAutoLinkDialogShowing = false
                                controller?
                                    .dismiss(animated: true, completion: nil)
                            }
                        )
                        controller = UIHostingController(
                            rootView: AnyView(view)
                        )
                        controller?.overrideUserInterfaceStyle = .light
                        controller?.modalPresentationStyle = .overCurrentContext // or .overFullScreen
                        controller?.view.backgroundColor = UIColor(
                            white: 0,
                            alpha: 0.3
                        )
                        if let topVC = self.getRootViewController() {
                            var visibleVC = topVC
                            while let presented = visibleVC.presentedViewController {
                                visibleVC = presented
                            }
                            visibleVC
                                .present(
                                    controller!,
                                    animated: true,
                                    completion: nil
                                )
                        } else {
                            print(
                                "❌ Could not find root view controller to present LinkAccountView!"
                            )
                        }
                        self.autoLinkRemainingSeconds = self.autoLinkPopupInterval
                    }
                }
            }
    }
    
    @objc public func stopAutoLinkAccountLoop() {
        autoLinkTimer?.invalidate()
        autoLinkTimer = nil
    }
    
    @MainActor private func showMenu(
        session: AuthSessionResponse?,
        error: String? = nil
    ) {
        let menuView = MenuView(
            accessToken: session?.accessToken,
            refreshToken: session?.refreshToken,
            error: error,
            onClickSignIn: {
                DispatchQueue.main.async {
                    self.getRootViewController()?
                        .dismiss(animated: true, completion: {
                            DispatchQueue.main.async {
                                self.Auth()
                            }
                        })
                }
            },
            onClickSignOut: {
                DispatchQueue.main.async {
                    self.hostingController?
                        .dismiss(animated: true, completion: {
                            self.showLogout(session: session)
                        })
                }
            },
            onClickItems: {
                DispatchQueue.main.async {
                    self.hostingController?
                        .dismiss(animated: true, completion: {
                            self.showPackageItems(session: session!)
                        })
                }
            },
            onClickGetGameServers: {
                DispatchQueue.main.async {
                    self.hostingController?
                        .dismiss(animated: true, completion: {
                            self.showGameServerView(session: session)
                        })
                }
            },
            onClickLatestSession: {
                self.getLatestSession()
            },
            onClickRefreshToken: {
                self.refreshToken(session: session)
            },
            onClickUserBlocked: {
                if let session = session {
                    self.showUserBlockedView(data: session)
                }
            },
            onClickTokenExpiration: {
                if let session = session {
                    self.showTokenExpiration(/*session: session*/)
                }
            },
            onClickDeleteAccount: {
                DispatchQueue.main.async {
                    self.hostingController?
                        .dismiss(animated: true, completion: {
                            self.showDeactivateAccount(session: session)
                        })
                }
                
            }
        )
        let controller = UIHostingController(rootView: AnyView(menuView))
        controller.modalPresentationStyle = .overFullScreen
        controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        self.hostingController = controller // ✅ store for later dismissal
        self.presentingVC?.present(controller, animated: true, completion: nil)
    }
    
    @MainActor func getRootViewController() -> UIViewController? {
        // Try the key window's root view controller
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    
    @MainActor public func showUserBlockedView(data: AuthSessionResponse) {
        let view = UserBlockedView(
            phoneNumber: "+84398686854",
            fanpage: "https://www.facebook.com/profile.php?id=61574162151534",
            onClose: {
                NSLog ( "---- KKSOFT Proxy Auth User Blocked" )
                let ret = "USER_BLOCKED".toDictionnary()
                self.Callback ( jsonPairs : ret )
                
                self.getRootViewController()?.dismiss(animated: true, completion: {
                    self.showMenu(session: nil)}
                )
            }
        )
        let ret = data.toDictionnary(responseCode: "USER_BLOCKED")
        self.Callback ( jsonPairs : ret )
        
        let controller = UIHostingController(rootView: AnyView(view))
        controller.overrideUserInterfaceStyle = .light
        controller.modalPresentationStyle = .overFullScreen
        controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.hostingController = controller
        self.presentingVC?.dismiss(animated: true, completion: {
            self.presentingVC?.present(controller, animated: false, completion: nil)
        })
    }

    @MainActor @objc public func showTokenExpiration(/*session: AuthSessionResponse*/) {
        let view = TokenExpirationView() {
            DispatchQueue.main.async {
                self.presentingVC?.dismiss(animated: true, completion: {
                    self.Auth()
                })
            }
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
    
    @MainActor private func showGameServerView(data: AuthSessionResponse) {
        let view = GameServerView (
            authManager : self.authManager,
            onUpdatedGameServer: { gameServerId, gameUUID in
                NSLog ( "---- KKSOFT Proxy UPDATE_GAME_SERVER " )
                let ret = data.copy(gameUUID: gameUUID,serverId: gameServerId)
                    .toDictionnary(responseCode: "UPDATE_GAME_SERVER")
                self.Callback ( jsonPairs : ret )
                self.hostingController?.dismiss(animated: true, completion: { self.showMenu(session: data)})
            }
        )
        let controller = UIHostingController(rootView: AnyView(view))
        controller.overrideUserInterfaceStyle = .light
        controller.modalPresentationStyle = .overFullScreen
        controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.hostingController = controller
        self.presentingVC?.dismiss(animated: true, completion: {
            self.presentingVC?.present(controller, animated: false, completion: nil)
        })
    }
    
    @MainActor private func showForceUpdateView() {
        var jsonPairs : [ String : Any ]
        jsonPairs = [ : ]
        jsonPairs [ "ResponseCode" ] = KKSOFTProxy.ResponseCodes [ "FORCE_UPDATE" ]
        jsonPairs [ "ResultCode" ] = KKSOFTProxy.ResultCodes [ "SUCCESS" ]
        self.Callback(jsonPairs: jsonPairs)
        
        let forceUpdateView = ForceUpdateView(appStoreId: "123")
        let controller = UIHostingController(rootView: AnyView(forceUpdateView))
        controller.modalPresentationStyle = .overFullScreen
        controller.overrideUserInterfaceStyle = .light
        controller.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.presentingVC?.present(controller, animated: true, completion: nil)
    }
}

extension String {
    func toDictionnary() -> [String: Any] {
        var jsonPairs : [ String : Any ]
        jsonPairs = [ : ]
        jsonPairs [ "ResponseCode" ] = KKSOFTProxy.ResponseCodes [ self ]
        jsonPairs [ "ResultCode" ] = KKSOFTProxy.ResultCodes [ "CANCEL" ]
        return jsonPairs
    }
}

extension AuthErrorResponse {
    func toDictionary() -> [String: Any] {
        var jsonPairs = [String : Any]()
        jsonPairs [ "ResponseCode" ] = KKSOFTProxy.ResponseCodes [ "AUTH" ]
        jsonPairs [ "ResultCode" ] = KKSOFTProxy.ResultCodes [ "FAIL" ]
        jsonPairs [ "Code" ] = self.code.id
        jsonPairs [ "Message" ] = self.message
        return jsonPairs
    }
}

extension AuthSessionResponse {
    func toDictionnary(responseCode: String) -> [String: Any] {
        var jsonPairs : [ String : Any ]
        jsonPairs = [ : ]
        jsonPairs [ "ResponseCode" ] = KKSOFTProxy
            .ResponseCodes [ responseCode ]
        jsonPairs [ "ResultCode" ] = KKSOFTProxy.ResultCodes [ "SUCCESS" ]
        jsonPairs [ "GameUUID" ] =  self.gameUUID
        jsonPairs [ "ServerID" ] =  self.serverId
        jsonPairs [ "AccessToken" ] =  self.accessToken
        jsonPairs [ "RefreshToken" ] =  self.refreshToken
        jsonPairs [ "UserBlocked" ] =  self.userBlocked
        jsonPairs [ "GameBlocked" ] =  self.gameBlocked
        jsonPairs [ "ServerBlocked" ] =  self.serverBlocked
        return jsonPairs
    }
}
```

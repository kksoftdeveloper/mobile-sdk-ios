//
//  AuthSDKDemoViewModel.swift
//  AuthSDKExample
//
//  Created by X on 4/17/25.
//

import Foundation
import Combine
import AuthSDK
import SwiftUI
import PaymentSDK

@MainActor
class AuthSDKDemoViewModel: ObservableObject {
    @Published var activeAlert: AlertType?
    @Published var displayInfo: AuthSessionResponse? = nil
    @Published var authError: Error? = nil
    @Published var isLoading = false

    @Published var presentedPopup: PopupScreen?
    
    let appStoreId = "google-chrome/id535886823"
    let osVersion: String
    let authService: AuthServiceProvider
    var paymentManager: DefaultPaymentManager?
    var cancellables = Set<AnyCancellable>()
    var gameInfo: AuthInitResponse?
    @Published var remainingSeconds: Int64 = 0
    
    private nonisolated(unsafe) var timerCancellable: AnyCancellable?
    private var popupInterval: Int64 = 60  // seconds
    private let packageName = "io.dar.example.authsdkexample"
    
    deinit {
        timerCancellable?.cancel()
    }
    
    init() {
        self.osVersion = UIDevice.current.systemVersion
        let builder = AuthServiceProvider.Builder()
            .setOSVersion(osVersion)
            .setAppVersion("1.0.0")
        self.authService = builder.build()
        
       
    }
    
    func loadAuthentication() {
        self.displayInfo = KeychainManager.shared.loadAuthSession()
        
        if displayInfo == nil {
            presentedPopup = .wellcome
        } else {
            initSDK()
            startAutoLinkAccountLoop()
        }
    }
    
    func openSDK() {
        presentedPopup = .wellcome
    }
    
    func initSDK() {
        authService.authManager.initSDK(packageName: packageName, appVersion: AuthSDK.Environment.versionNumber)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.displayInfo = nil
                KeychainManager.shared.clearAuthSession()
//                switch completion {
//                case .failure(let error):
//                    print("❌ init game-info failed: \(String(describing: (error as? AuthErrorResponse)?.message))")
//                case .finished:
//                    break
//                }
            }, receiveValue: { gameInfo in
                let versionInfo = gameInfo.versionInfo
                self.gameInfo = gameInfo
//                let minAppVersion = versionInfo.minAppVersion
//                let currentVersion = AuthSDK.Environment.versionNumber
//                if versionInfo.forceUpdate && currentVersion.compare(minAppVersion, options: .numeric) == .orderedDescending {
                if versionInfo.forceUpdate {
                    // currentVersion < minAppVersion
                    self.presentedPopup = .forceUpdate
                }
                self.authService.authManager.getAuthSesssion()
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { completion in
                            self.displayInfo = nil
                            KeychainManager.shared.clearAuthSession()
                        },
                        receiveValue: { session in
                            if session.accessToken != nil && !session.accessToken.isEmpty {
                                self.displayInfo = session
                                KeychainManager.shared.saveAuthSession(session)
                                if(session.gameUUID == nil) {
                                    self.presentedPopup = .gameServer
                                }
                            } else {
                                self.presentedPopup = .wellcome
                            }
                        }
                    )
            })
            .store(in: &cancellables)
    }
    
    private func initPaymentSDK(gameId: Int, serverId: Int) {
        let authSession = KeychainManager.shared.loadAuthSession()
        let paymentbuilder = DefaultPaymentManager.Builder()
            .setOSVersion(osVersion)
            .setAppVersion("1.0.0")
            .setAccessToken(authSession?.accessToken ?? "")
            .setDeviceId(authService.authManager.getDeviceID())
            .setPackageName(packageName)
            .setGameId(gameId)
            .setServerId("\(authService.authManager.getServerId() ?? 0)")
            .setGameUUID(authSession?.gameUUID ?? "")
            .setPhoneNumber(authService.authManager.getPhoneNumber())
        do {
            paymentManager = try paymentbuilder.build()
        } catch {
            print("❌ Failed to initialize PaymentManager: \(error)")
            paymentManager = nil
        }
    }
        
    func refreshToken() {
        isLoading = true
        authService.authManager.refreshToken()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                isLoading = false
                switch completion {
                case .failure(let error):
                    print("❌ Refresh Token Error: \(error)")
                    let description = error.getErrorDescription()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.activeAlert = .onFail(description)
                    }
                case .finished:
                    break
                }
                
            }, receiveValue: { [weak self] data in
                guard let self else { return }
                print("✅ Refresh Token Success: \(data.accessToken)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    KeychainManager.shared.saveAuthSession(data)
                    self.displayInfo = data
                }
            })
            .store(in: &cancellables)
    }
    
    func getLatestSession() {
        isLoading = true
        authService.authManager.getAuthSesssion()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                isLoading = false
                switch completion {
                case .failure(let error):
                    print("❌ Refresh Token Error: \(error)")
                    let description = error.getErrorDescription()
                case .finished:
                    break
                }
                
            }, receiveValue: { [weak self] data in
                guard let self else { return }
                print("✅ Refresh Token Success: \(data)")
                KeychainManager.shared.saveAuthSession(data)
                self.displayInfo = data
            })
            .store(in: &cancellables)
    }
    
    func logout() {
        authService.authManager.logout()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                isLoading = false
                switch completion {
                case .failure(let error):
                    print("❌ Logout Error: \(error)")
                    let description = error.getErrorDescription()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.activeAlert = .onFail(description)
                    }
                case .finished:
                    break
                }
                
            }, receiveValue: { [weak self] data in
                guard let self else { return }
                self.displayInfo = nil
                KeychainManager.shared.clearAuthSession()
                print("✅ Logout Success: \(data)")
            })
            .store(in: &cancellables)
    }
    
    func handleSuccess(data: AuthSessionResponse) {
        self.displayInfo = data
        if displayInfo?.gameUUID == nil {
            presentedPopup = .gameServer
        } else {
            presentedPopup = nil
        }
        authError = nil
        KeychainManager.shared.saveAuthSession(data)
        self.initPaymentSDK(gameId: gameInfo?.gameInfo.gameId ?? 0, serverId: displayInfo?.serverId ?? 0)
    }
    
    func handleFail(error: Error) {
        presentedPopup = nil
        authError = error
    }
    
    func deactiveAccount() {
        isLoading = true
        authService.authManager
            .deactivateAccount()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {[weak self] completion in
                guard let self else { return }
                isLoading = false
                switch completion {
                case .failure(let error):
                    print("❌ Deactive Error: \(error)")
                    let description = error.getErrorDescription()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.activeAlert = .onFail(description)
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] data in
                guard let self else { return }
                isLoading = false
                self.displayInfo = nil
                KeychainManager.shared.clearAuthSession()
                print("✅ Deactive Success: \(data)")
            })
            .store(in: &cancellables)
    }
}

extension AuthSDKDemoViewModel {
    
    /// Call this once when you know `displayInfo` is set and isNewUser == true
    func startAutoLinkAccountLoop(timeToRemindInSeconds: Int64 = 60) {
        // reset & cancel any existing timer
        stopAutoLinkAccountLoop()
        popupInterval = displayInfo?.loginReminderResponse?.loginAfterSeconds ?? timeToRemindInSeconds
        timerCancellable?.cancel()
        remainingSeconds = popupInterval
        
        // create a publisher that fires every 1s
        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                guard let info = self.displayInfo, info.loginReminderResponse != nil, info.gameUUID != nil else {
                    self.remainingSeconds = self.popupInterval
                    return
                }
                
                let desired = PopupScreen.linkAccount(guestToken: self.displayInfo?.accessToken ?? "")
                if self.presentedPopup == desired {
                    return
                }
                
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                    print("⏳ Link popup in \(self.remainingSeconds)s")
                } else {
                    // time’s up → show the popup
                    print("🔔 Showing LinkAccountView now")
                    self.presentedPopup = .linkAccount(guestToken: self.displayInfo?.accessToken ?? "")
                    // reset for next round
                    self.remainingSeconds = self.popupInterval
                }
            }
         
    }
    
    func stopAutoLinkAccountLoop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func waitForDismiss() async {
        while presentedPopup == .linkAccount(guestToken: displayInfo?.accessToken ?? "") {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
}


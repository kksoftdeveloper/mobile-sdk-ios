//
//  AuthSDKDemoView.swift
//  AuthSDKExample
//
//  Created by Damon on 4/17/25.
//

import SwiftUI
import AuthSDK
import PaymentSDK
//import AppTrackingTransparency

struct AuthSDKDemoView: View {
    @ObservedObject private var viewModel: AuthSDKDemoViewModel
    
    init(viewModel: AuthSDKDemoViewModel) {
        self.viewModel = viewModel
    }
    
    
    var body: some View {
//        ScrollView {
            content
            .popup(
                    item: $viewModel.presentedPopup, backgroundOpacity: 0.4, dismissOnTapOutside: false
                ) { screen, dismiss in
                    switch screen {
                    case .wellcome:
                        sdkEntryPointView(onDismiss: dismiss)
                    case .forceUpdate:
                        ForceUpdateView() {
                            if let url = URL(string: "https://apps.apple.com/app/" + viewModel.appStoreId) {
                                UIApplication.shared.open(url)
                            }
                        }
                    case .logoutConfirm:
                        LogoutConfirmView {
                            viewModel.presentedPopup = nil
                        } onConfirm: {
                            viewModel.logout()
                            viewModel.presentedPopup = nil
                        }
                    case .gameServer:
                        GameServerView(
                            authManager: viewModel.authService.authManager,
                            onClose: {
                                viewModel.presentedPopup = nil
                            }
                        )
                    case .sdk:
                        sdkEntryPointView(onDismiss: dismiss)
                    case .linkAccount(let accessToken):
                        popuplinkAccount(onDismiss: dismiss)
                    case .packageList:
                        PackageListView(viewModel: .init(paymentManager: viewModel.paymentManager), onCloseClick: {
                            viewModel.presentedPopup = nil
                        })
                    default:
                        EmptyView()
                    }
                }
                .overlay(
                    Group {
                        if viewModel.isLoading {
                            ZStack {
                                Color.black.opacity(0.4)
                                    .ignoresSafeArea()
                                ProgressView("Loading...")
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 10)
                            }
                        }
                    }
                )
                .alert(item: $viewModel.activeAlert) { alert in
                    switch alert {
                    case .onFail(let message):
                        return Alert(
                            title: Text("Opps!"),
                            message: Text(message),
                            dismissButton: .default(Text("OK"))
                        )
                    case .onSuccess(let message):
                        return Alert(
                            title: Text("Success"),
                            message: Text(message),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
//        }
        .onAppear {
            AuthSDK.FontLoader.loadAllFonts()
//            viewModel.initSDK()
//            viewModel.startAutoLinkAccountLoop()
            viewModel.loadAuthentication()
//            requestTrackingPermissionIfNeeded()
        }
        .onDisappear() {
            viewModel.stopAutoLinkAccountLoop()
        }
    }
    
    @ViewBuilder private var content: some View {
        VStack(spacing: 20) {
            Text("Token Management")
                .font(.largeTitle.bold())
                .padding(.bottom, 20)
            
            VStack (spacing: 16) {
                button(action: viewModel.openSDK,
                       label: "Sign Up & Login",
                       systemIcon: "person.fill.badge.plus",
                       isEnabled: viewModel.displayInfo == nil
                )
                
                button(action: {
                    if let accessToken = viewModel.displayInfo?.accessToken {
                        viewModel.presentedPopup = .linkAccount(guestToken: accessToken)
                    }

                },
                       label: "Login Reminder in \(String(describing: viewModel.remainingSeconds))s",
                       systemIcon: "arrow.trianglehead.2.clockwise.rotate.90",
                       isEnabled: viewModel.displayInfo?.isNewUser == false
                )
                
                button(action: viewModel.refreshToken,
                       label: "Refresh Token",
                       systemIcon: "arrow.trianglehead.2.clockwise.rotate.90",
                       isEnabled: viewModel.displayInfo != nil
                )
                
                button(action: viewModel.getLatestSession,
                       label: "Get Latest Session",
                       systemIcon: "arrow.trianglehead.2.clockwise.rotate.90",
                       isEnabled: viewModel.displayInfo != nil
                )
                
                button(action:{
                    viewModel.presentedPopup = .packageList
                },
                       label: "Buy Items",
                       systemIcon: "rectangle.portrait.and.trolley.fill",
                       isEnabled: viewModel.displayInfo != nil
                )
                
                button(action:{
                    viewModel.presentedPopup = .logoutConfirm
                },
                       label: "Logout",
                       systemIcon: "rectangle.portrait.and.arrow.right",
                       isEnabled: viewModel.displayInfo != nil
                )
                
                button(action: viewModel.deactiveAccount,
                       label: "Delete Account",
                       systemIcon: "rectangle.portrait.and.arrow.close",
                       isEnabled: viewModel.displayInfo != nil
                )
            }
            
            if let error = viewModel.authError {
                VStack (alignment: .leading, spacing: 8)  {
                    Text("Error:")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.init(uiColor: .darkGray))
                    
                    let message = error.getErrorDescription()
                    Text("\(message)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(.gray.opacity(0.2))
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .cornerRadius(8)
                        .multilineTextAlignment(.leading)
                    
                }
                .padding()
                .background(.white)
                .cornerRadius(8)
            }
//            else  {
//                VStack (alignment: .leading, spacing: 8)  {
//                    Text("Access Token")
//                        .fontWeight(.semibold)
//                        .foregroundColor(Color.init(uiColor: .darkGray))
//                    
//                    Text("\(viewModel.displayInfo?.accessToken ?? "")")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(8)
//                        .background(.gray.opacity(0.2))
//                        .fontWeight(.semibold)
//                        .foregroundColor(.black)
//                        .cornerRadius(8)
//                        .multilineTextAlignment(.leading)
//                    
//                }
//                .padding()
//                .background(.white)
//                .cornerRadius(8)
//                
//                VStack (alignment: .leading, spacing: 8)  {
//                    Text("Refresh Token")
//                        .fontWeight(.semibold)
//                        .foregroundColor(Color.init(uiColor: .darkGray))
//                    
//                    Text("\(viewModel.displayInfo?.refreshToken ?? "")")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(8)
//                        .background(.gray.opacity(0.2))
//                        .fontWeight(.semibold)
//                        .foregroundColor(.black)
//                        .cornerRadius(8)
//                        .multilineTextAlignment(.leading)
//                    
//                }
//                .padding()
//                .background(.white)
//                .cornerRadius(8)
//            }
            
            Spacer()
        }
        .padding()
        .background(.gray.opacity(0.1))
    }
    
    private func sdkEntryPointView(onDismiss: @escaping () -> Void?) -> some View {
         return WelcomeView(
                authManager: viewModel.authService.authManager,
                packageName: "io.dar.example.authsdkexample",
                appVersionName: "1.0.0",
                onSuccess: { data in
                    viewModel.handleSuccess(data: data)
                },
                onFailure: { errorMessage in
                    viewModel.handleFail(error: errorMessage)
                },
                onClose: {
                    onDismiss()
                }
            )
    }
    
    private func popuplinkAccount(onDismiss: @escaping () -> Void?) -> some View {
        return LinkAccountView(
            authManager: viewModel.authService.authManager,
            guestToken: viewModel.displayInfo!.accessToken,
            onSuccess: { authSession in print("link account success \(authSession)")},
            onFailure: { authError in },
            onClose: {
                onDismiss()
            }
        )
    }

    private func button(
        action: @escaping @MainActor () -> Void,
        label: String,
        systemIcon: String = "",
        isEnabled: Bool = true
    ) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                if !systemIcon.isEmpty {
                    Image(systemName: systemIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                
                Text(label)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isEnabled ? Color.primaryText : Color.gray)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.buttonBackground : Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
        .padding(.horizontal, 8)
        .disabled(!isEnabled)
    }

//    private func requestTrackingPermissionIfNeeded() {
//        if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization { status in
//                switch status {
//                case .authorized:
//                    print("✅ Tracking authorized")
//                case .denied, .notDetermined, .restricted:
//                    print("❌ Tracking not allowed")
//                @unknown default:
//                    break
//                }
//            }
//        }
//    }
}

extension Error {
    func getErrorDescription() -> String {
        if let authError = self as? AuthErrorResponse {
            return authError.message
        } else if let localizedError = self as? LocalizedError {
            return localizedError.errorDescription ?? self.localizedDescription
        } else {
            return self.localizedDescription
        }
    }
}

enum AlertType: Identifiable {
    case onFail(String)
    case onSuccess(String)
    
    var id: String {
        switch self {
        case .onFail(let message):
            return message
        case .onSuccess(let message):
            return message
        }
    }
}

extension Color {
    static var primaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? .black :  .white
        })
    }
    
    static var buttonBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : .black
        })
    }
}

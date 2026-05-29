//
//  SignUpViewModel.swift
//  AuthSDK
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PhoneNumberInputViewModel: OpenViewModel {
    @Published var flowType: FlowType
    @Published var phoneNumber = ""
    @Binding var presentedScreen: PopupScreen?
    @Published var isAcceptedTerm = false
    @Published var isValidPhoneNumber: Bool = false
    @Published var isOTPRequestManyTime = false
    @Published var isAccountExisted     = false
    @Published var errorMessage: LocalizedStringKey? = nil
    @Published var resendCountdown:  Int = 0
    let authManager: AuthManager

    init(flowType: FlowType, presentedScreen: Binding<PopupScreen?>, authManager: AuthManager) {
        self.flowType = flowType
        self._presentedScreen = presentedScreen
        self.authManager = authManager
        super.init()
        
        $phoneNumber
            .map { $0.isValidPhoneNumber()}
            .assign(to: \.isValidPhoneNumber, on: self)
            .store(in: &cancellables)
    }
    
    func handleContinue(otpSendableResponse: OTPSendableResponse) {
        if isValidPhoneNumber {
            presentedScreen = .otpInput(type: flowType, phoneNumber: phoneNumber, otpSendableResponse: otpSendableResponse)
        }
    }
    
    var requiresTermsAcceptance: Bool {
        flowType == .register || flowType == .linkToNewAccount
    }
    
    var isPrimaryButtonEnabled: Bool {
        isValidPhoneNumber && (requiresTermsAcceptance ? isAcceptedTerm : true)
    }

    func requestOTP() {
        resetState()
        performRequest(
            publisher: otpRequestPublisher(),
            onSuccess: { [weak self] otpSendableResponse in
                guard let self else { return }
                self.handleContinue(otpSendableResponse: otpSendableResponse)
            }
        )
    }
    
    private func resetState() {
        isLoading             = false
        isOTPRequestManyTime  = false
        isAccountExisted      = false
        errorMessage          = nil
    }
    
    private func performRequest<P: Publisher>(
      publisher: P,
      onSuccess: @escaping (P.Output) -> Void
    ) where P.Failure == Error {
        isLoading = true
        publisher
          .receive(on: DispatchQueue.main)
          .handleEvents(receiveCompletion: { [weak self] _ in
              self?.isLoading = false
          })
          .sink { [weak self] completion in
              guard let self else { return }
              if case .failure(let err) = completion {
                  if let apiErr = err as? AuthErrorResponse, apiErr.code == .AccountNotExist  {
                      self.errorMessage = .sdkAsset("account_isnot_registered")
                      return
                  }
                  self.errorMessage = .sdkAsset("server_error")
              }
          } receiveValue: { output in
              onSuccess(output)
          }
          .store(in: &cancellables)
    }
    
    private func otpRequestPublisher() -> AnyPublisher<OTPSendableResponse, Error> {
        switch flowType {
        case .register, .linkToNewAccount:
            return authManager.requestOTP(phone: phoneNumber)
        case .forgetPassword:
            return authManager.requestOTPForgetPassword(phone: phoneNumber)
        }
    }
    
    override func handleApiError(_ apiError: AuthErrorResponse) {
        switch apiError.code {
        case .OTPRequestManyTime:
            isOTPRequestManyTime = true
            errorMessage         = .sdkAsset("otp_request_many_times")
        case .SocialAccountLinked:
            isAccountExisted     = true
            errorMessage         = .sdkAsset("account_existed")
        default:
            super.handleApiError(apiError)
            errorMessage = .sdkAsset("unknown_error_message")
        }
    }
}

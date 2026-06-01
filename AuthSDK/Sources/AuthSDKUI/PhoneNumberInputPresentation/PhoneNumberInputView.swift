//
//  SignUpView.swift
//  AuthSDK
//

import SwiftUI

struct PhoneNumberInputView: View {
    @StateObject var viewModel: PhoneNumberInputViewModel
    
    @FocusState private var phoneFocused: Bool
    @SwiftUI.Environment(\.verticalSizeClass) private var verticalSizeClass
    
    init(flowType: FlowType, presentedScreen: Binding<PopupScreen?>, authManager: AuthManager) {
        self._viewModel = StateObject(wrappedValue: PhoneNumberInputViewModel(
            flowType: flowType,
            presentedScreen: presentedScreen,
            authManager: authManager
        ))
    }
    
    var body: some View {
        GeometryReader { geo in
            
            let isLandscape = verticalSizeClass == .compact
            
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let width = UIScreen.main.bounds.size.width
            let height = UIScreen.main.bounds.size.height
            let minValue = min(width, height, CGFloat((isPad ? 440 : Int.max)))
            let contentWidth = isLandscape ? minValue*0.8*0.9 : minValue
            let contentHeight = isLandscape ? minValue*0.9 : minValue*1.2
            
            content(
                width: contentWidth,
                height: contentHeight
            )
            .preferredColorScheme(.light)
            .frame(
                width: geo.size.width,
                height: geo.size.height,
                alignment: .center
            )
            .navigationBarHidden(true)
        }
        .onAppear {
            // Wait until the popup’s show animation completed so the field can become first responder.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                phoneFocused = true
            }
        }
    }
    
    @ViewBuilder
    private func content(width: CGFloat, height: CGFloat) -> some View
    {
        AuthContainer(
            wid: width,
            hei: height,
            onCloseClick: {
            viewModel.presentedScreen = nil
        }) {
            VStack {
                Group {
                    Text(.sdkAsset("step")) + Text(" 1 / 3")
                }
                .font(AppFont.fsClanNarrowUltra.of(size: 14))
                .foregroundColor(.secondaryText)
                .padding(.vertical, 5)
                
                Text(FlowType.register.title)
                    .font(AppFont.fsClanNarrowUltra.of(size: 16))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
                
                Text(viewModel.flowType.subtitleText)
                    .font(AppFont.poppinsRegular.of(size: 12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primaryText)
                    .padding(.bottom, 12)
                
                VStack (alignment: .leading ,spacing: 4) {
                    Text(.sdkAsset("phone_number"))
                        .font(AppFont.poppinsRegular.of(size: 12))
                        .foregroundColor(.secondaryText)
                    PhoneNumberInputText(phoneNumber: $viewModel.phoneNumber)
                        .focused($phoneFocused)
                        .onChange(of: viewModel.phoneNumber) { newValue in
                            viewModel.phoneNumber = newValue.trimmedVietnamPhoneNumber()
                        }
                }
                .padding(.horizontal, 20)
                if (viewModel.flowType == .register || viewModel.flowType == .linkToNewAccount || viewModel.flowType == .forgetPassword) {
                    CheckedBoxText(
                        lineLimit: 2,
                        isChecked: $viewModel.isAcceptedTerm,
                        text: "",
                        onToggle: { newValue in
                            viewModel.isAcceptedTerm = newValue
                        }
                    )
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                }
                MeasuredBox {
                    let message: LocalizedStringKey? = viewModel.errorMessage
                    ValidationMessageText(textKey: message, size: 12, isValid: false)
                        .layoutPriority(1)
                }
                .padding(.top, 8)
                .padding(.horizontal, 0)
            }
            .padding(.horizontal, verticalSizeClass == .compact ? 10 : 50)
        } footer: {
            let primaryButtonWidth = width*0.46
            PrimaryButton(
                action: {
                    viewModel.requestOTP()
                },
                label: {
                    Text(viewModel.flowType.buttonText)
                },
                isDisabled: !viewModel.isPrimaryButtonEnabled
            )
            .frame(width: primaryButtonWidth, height: primaryButtonWidth*0.35)
        }
    }
}

private extension FlowType {
    var title: String {
        switch self {
        case .register, .forgetPassword, .linkToNewAccount:
            return LocalizedStringKey.sdkAsset("input_your_phone_number").toString().uppercased()
        }
    }
    
    var subtitleText: String {
        switch self {
        case .register, .forgetPassword, .linkToNewAccount:
            return LocalizedStringKey.sdkAsset("we_will_send_you_verify_code").toString()
        }
    }
    
    var buttonText: String {
        switch self {
        case .register, .linkToNewAccount, .forgetPassword:
            return LocalizedStringKey.sdkAsset("receive_otp").toString()
        }
    }
}

#Preview {
    PhoneNumberInputView(flowType: .register, presentedScreen: .constant(nil), authManager: DefaultAuthManager.Builder().build())
}

import SwiftUI

public struct PopUpView: View {
    
    private let title: String
    private let description: String
    private let submitButtonTitle: String
    
    private let onClose: () -> Void
    private let onSubmit: () -> Void
    
    public init(title: String, description: String, submitButtonTitle: String, onClose: @escaping () -> Void = { }, onSubmit: @escaping () -> Void = { }) {
        self.title = title
        self.description = description
        self.submitButtonTitle = submitButtonTitle
        self.onClose = onClose
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        content
            .preferredColorScheme(.light)
    }
    
    
    @ViewBuilder
    private var content: some View {
        SquareContainer(onCloseClick: {
            onClose()
        }, content: {
            VStack {
                Text(title)
                    .font(AppFont.fsClanNarrowUltra.of(size: 16))
                    .foregroundColor(.primaryText)
                    .padding(.vertical, 15)
                Text(description)
                    .font(AppFont.poppinsLight.of(size: 12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primaryText)
                    .padding(.horizontal, 30)
            }
        }, footer: {
            PrimaryButton(
                action: {
                    onSubmit()
                },
                label: {
                    Text(submitButtonTitle)
                },
                isDisabled: false
            )
            .frame(width: 144, height: 36)
        })
    }
}

#Preview {
    PopUpView(title: "Thanh toán thành công!", description: "Chúc mừng đại hiệp đã mua thành công gói vật phẩm ABC. Vật phẩm đã được gởi vào túi hành lí", submitButtonTitle: "Đóng", onClose: {}, onSubmit: {})
}

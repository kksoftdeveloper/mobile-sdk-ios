//
//  File.swift
//  AuthSDK
//
//  Created by Admin on 4/29/25.
//

import Foundation
import SwiftUI

struct SquareContainer<Content: View, Footer: View>: View {
    
    private let shouldShowCross: Bool
    private let onCloseClick: () -> Void
    private let content: () -> Content
    private let footer: () -> Footer
    
    init(
        shouldShowCross: Bool = true,
        onCloseClick: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer = {EmptyView()}
    ) {
        self.shouldShowCross = shouldShowCross
        self.content = content
        self.onCloseClick = onCloseClick
        self.footer = footer
    }
    
    var body: some View {
        let fullWidth = min( UIScreen.main.bounds.size.width, 375)
        ZStack() {
            Image(sdkAsset: "RectangleBackground")
                .padding(.vertical, 36)
            content()
        }
        .frame(width: fullWidth)
        .overlay(alignment: .topTrailing, content: {
            if(shouldShowCross) {
                Button(action: onCloseClick) {
                    Image(sdkAsset: "IconCross")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            } else {
                EmptyView()
            }
        })
        .overlay(alignment: .bottom, content: {
            footer()
                .frame(width: fullWidth)
                .padding(.bottom, 24)
        })
    }
}

#Preview {
    SquareContainer(
        shouldShowCross: true,
        onCloseClick: {
            
        })
    {
    } footer: {
        PrimaryButton(action: {}, label: {
            Text(.sdkAsset("login"))
        }, isDisabled: (false))
        .frame(width: 144, height: 36)
    }
}

import Foundation
import SwiftUI


enum AppFont: String, CaseIterable {
    case poppinsRegular         = "Poppins-Regular"
    case poppinsThin            = "Poppins-Thin"
    case poppinsLight           = "Poppins-Light"
    case poppinsLightItalic     = "Poppins-LightItalic"
    case poppinsMedium          = "Poppins-Medium"
    case poppinsSemiBold        = "Poppins-SemiBold"
    case poppinsBold            = "Poppins-Bold"
    case fsClanNarrowUltra      = "FSClanPro-NarrowUltra"
    
    func of(size: CGFloat, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        Font.custom(rawValue, size: size, relativeTo: textStyle)

    }
}

extension Font {
    static var themeBody: Font {
        AppFont.poppinsLight.of(size: 16, relativeTo: .body)
    }
    
    static var themeTitle: Font {
        AppFont.poppinsSemiBold.of(size: 24, relativeTo: .title)
    }
    
    static var themeHeading: Font {
        AppFont.fsClanNarrowUltra.of(size: 20, relativeTo: .headline)
    }
}

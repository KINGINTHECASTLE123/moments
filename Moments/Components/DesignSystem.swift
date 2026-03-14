import SwiftUI

enum MomentsStyle {
    // MARK: - Colors
    static let background = Color.white
    static let primaryText = Color(red: 0.1, green: 0.094, blue: 0.078) // #1A1814
    static let secondaryText = Color(red: 0.6, green: 0.6, blue: 0.6) // #999999
    static let border = Color(red: 0.91, green: 0.898, blue: 0.878) // #E8E5E0
    static let inactive = Color(red: 0.8, green: 0.8, blue: 0.8) // #CCCCCC

    // MARK: - Corner Radii
    static let cardRadius: CGFloat = 12
    static let buttonRadius: CGFloat = 40

    // MARK: - Fonts
    static func georgiaItalic(_ size: CGFloat) -> Font {
        .custom("Georgia-Italic", size: size)
    }

    static func systemLight(_ size: CGFloat) -> Font {
        .system(size: size, weight: .light)
    }

    static func systemRegular(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular)
    }

    static func systemMedium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium)
    }
}

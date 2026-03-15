import SwiftUI
import UIKit

enum MomentsStyle {
    // MARK: - Colors (adaptive for light/dark mode)
    static let background = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.1, green: 0.094, blue: 0.078, alpha: 1)    // #1A1814
            : .white
    })

    static let primaryText = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.96, green: 0.953, blue: 0.941, alpha: 1)   // #F5F3F0
            : UIColor(red: 0.1, green: 0.094, blue: 0.078, alpha: 1)    // #1A1814
    })

    static let secondaryText = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.467, green: 0.467, blue: 0.467, alpha: 1)  // #777777
            : UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)       // #999999
    })

    static let border = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.173, blue: 0.157, alpha: 1)   // #2E2C28
            : UIColor(red: 0.91, green: 0.898, blue: 0.878, alpha: 1)   // #E8E5E0
    })

    static let inactive = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.333, green: 0.333, blue: 0.333, alpha: 1)  // #555555
            : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)       // #CCCCCC
    })

    static let cardBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.141, green: 0.133, blue: 0.125, alpha: 1)  // #242220
            : .white
    })

    static let surfaceSecondary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.173, blue: 0.157, alpha: 1)   // #2E2C28
            : UIColor(red: 0.96, green: 0.955, blue: 0.945, alpha: 1)   // #F5F4F1
    })

    static let accent = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.78, green: 0.72, blue: 0.62, alpha: 1)     // #C7B89E warm gold
            : UIColor(red: 0.1, green: 0.094, blue: 0.078, alpha: 1)    // #1A1814
    })

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

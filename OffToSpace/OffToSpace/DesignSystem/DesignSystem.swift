import SwiftUI

enum DesignSystem {

    enum Colors {

        static let background = adaptive(
            light: 0xF4F7FB,
            dark: 0x080F19
        )

        static let cardBackground = adaptive(
            light: 0xFFFFFF,
            dark: 0x141C28
        )

        static let imagePlaceholder = adaptive(
            light: 0xE3E9F0,
            dark: 0x253244
        )

        static let secondarySurface = adaptive(
            light: 0xEDF2F8,
            dark: 0x1D2838
        )

        static let primaryText = Color.primary
        static let secondaryText = Color.secondary

        static let tertiaryText = adaptive(
            light: 0x78869B,
            dark: 0x8594A9
        )

        static let accent = adaptive(
            light: 0x0866F5,
            dark: 0x2583FF
        )

        static let successBackground = adaptive(
            light: 0xD7F7E5,
            dark: 0x155C3B
        )

        static let successText = adaptive(
            light: 0x087443,
            dark: 0x75E7A0
        )

        static let failureBackground = adaptive(
            light: 0xFDECEC,
            dark: 0x5C1515
        )

        static let failureText = adaptive(
            light: 0xB42318,
            dark: 0xF5A3A3
        )

        static let upcomingBackground = adaptive(
            light: 0xDCEBFF,
            dark: 0x0A3A7A
        )

        static let upcomingText = adaptive(
            light: 0x0866F5,
            dark: 0x8CBCFF
        )

        static let separator = Color(uiColor: .separator)

        // MARK: - Helpers

        private static func adaptive(
            light: UInt32,
            dark: UInt32
        ) -> Color {
            Color(
                uiColor: UIColor { traits in
                    let hex = traits.userInterfaceStyle == .dark
                        ? dark
                        : light

                    return UIColor(
                        red: CGFloat((hex >> 16) & 0xFF) / 255,
                        green: CGFloat((hex >> 8) & 0xFF) / 255,
                        blue: CGFloat(hex & 0xFF) / 255,
                        alpha: 1
                    )
                }
            )
        }
    }

    enum Opacity {
        static let full: Double = 1
        static let pressedFilled: Double = 0.85
        static let pressedPlain: Double = 0.6
        static let faded: Double = 0.5
        static let disabled: Double = 0.4
        static let shadow: Double = 0.08
    }

    enum BorderWidth {
        static let thin: CGFloat = 1
    }

    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 40
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let xxLarge: CGFloat = 24
    }

    enum Size {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let tabIcon: CGFloat = 24
        static let image: CGFloat = 64
        static let launchThumbnailWidth: CGFloat = 72
        static let launchThumbnailHeight: CGFloat = 80
        static let qrCode: CGFloat = 240
        static let imageAspectRatio: CGFloat = 16 / 9
    }

    enum Fonts {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let largeTitleThinItalic = Font.largeTitle.weight(.thin).italic()
        static let title = Font.title.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)
        static let headline = Font.headline
        static let body = Font.body
        static let subheadline = Font.subheadline
        static let caption = Font.caption
        static let footnote = Font.footnote
    }
}

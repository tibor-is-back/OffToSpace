import SwiftUI

enum DesignSystem {
    enum Colors {
        static let primary = Color.indigo
        static let onPrimary = Color.white

        static let secondary = Color.teal

        static let screenBackground = Color(.systemGroupedBackground)
        static let surface = Color(.secondarySystemGroupedBackground)
        static let cardBackground = Color(.secondarySystemGroupedBackground)

        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        static let error = Color.red
        static let success = Color.green

        static let separator = Color(.separator)

        static let imagePlaceholder = Color(.tertiarySystemFill)
        static let imageOverlay = Color.black.opacity(0.6)
        static let onImageOverlay = Color.white
    }

    enum Opacity {
        static let full: Double = 1
        static let pressedFilled: Double = 0.85
        static let pressedPlain: Double = 0.6
        static let faded: Double = 0.5
        static let disabled: Double = 0.4
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
    }

    enum Size {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let image: CGFloat = 64
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

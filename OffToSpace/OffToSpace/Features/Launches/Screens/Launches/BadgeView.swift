import SwiftUI

struct BadgeView: View {
    enum Style {
        case success
        case error
        case neutral
        case info
    }

    let text: String
    let style: Style

    var body: some View {
        Text(text)
            .font(DesignSystem.Fonts.caption.weight(.semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, DesignSystem.Spacing.small)
            .padding(.vertical, DesignSystem.Spacing.xSmall)
            .background(backgroundColor, in: Capsule())
            .accessibilityIdentifier("launches.badge")
            .accessibilityLabel(Text(text))
    }

    private var backgroundColor: Color {
        switch style {
        case .info:
            DesignSystem.Colors.upcomingBackground
        case .success:
            DesignSystem.Colors.successBackground
        case .error:
            DesignSystem.Colors.failureBackground
        case .neutral:
            DesignSystem.Colors.secondarySurface
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .info:
            DesignSystem.Colors.upcomingText
        case .success:
            DesignSystem.Colors.successText
        case .error:
            DesignSystem.Colors.failureText
        case .neutral:
            DesignSystem.Colors.tertiaryText
        }
    }
}

#Preview("Successful") {
    BadgeView(text: LaunchesPreviewData.successful.status.text, style: .success)
}

#Preview("Failed") {
    BadgeView(text: LaunchesPreviewData.failed.status.text, style: .error)
}

#Preview("Upcoming") {
    BadgeView(text: LaunchesPreviewData.upcoming.status.text, style: .info)
}

#Preview("Unknown") {
    BadgeView(text: LaunchesPreviewData.unknownWithoutImage.status.text, style: .neutral)
}

#Preview("Dark Successful") {
    BadgeView(text: LaunchesPreviewData.successful.status.text, style: .success)
        .preferredColorScheme(.dark)
}

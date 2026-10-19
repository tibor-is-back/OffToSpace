import SwiftUI

struct LaunchListItemView: View {
    let data: LaunchesListItemViewData

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            RemoteImage(url: data.imageURL)
                .frame(
                    width: DesignSystem.Size.launchThumbnailWidth,
                    height: DesignSystem.Size.launchThumbnailHeight
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                )

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Text(data.name)
                    .font(DesignSystem.Fonts.headline)
                    .foregroundStyle(DesignSystem.Colors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(data.launchSite)
                    .font(DesignSystem.Fonts.subheadline)
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: DesignSystem.Spacing.small) {
                    Text(data.date)
                        .font(DesignSystem.Fonts.footnote)
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: .zero)

                    BadgeView(text: data.status.text, style: data.status.style)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }

            Image(systemName: "chevron.right")
                .font(DesignSystem.Fonts.subheadline)
                .foregroundStyle(DesignSystem.Colors.tertiaryText)
                .accessibilityHidden(true)
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Colors.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
        )
        .shadow(
            color: Color.black.opacity(DesignSystem.Opacity.shadow),
            radius: DesignSystem.Spacing.small,
            y: DesignSystem.Spacing.xSmall
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("launches.listItem.\(data.id)")
        .accessibilityHint("launches.listItem.hint")
    }

}

#Preview("Successful") {
    LaunchListItemView(data: LaunchesPreviewData.successful)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.background)
}

#Preview("Failed") {
    LaunchListItemView(data: LaunchesPreviewData.failed)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.background)
}

#Preview("Upcoming") {
    LaunchListItemView(data: LaunchesPreviewData.upcoming)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.background)
}

#Preview("Unknown") {
    LaunchListItemView(data: LaunchesPreviewData.unknownWithoutImage)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.background)
}

#Preview("Dark Successful") {
    LaunchListItemView(data: LaunchesPreviewData.successful)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}

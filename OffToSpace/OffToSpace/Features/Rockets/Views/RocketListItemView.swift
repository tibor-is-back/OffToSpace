import SwiftUI

struct RocketListItemView: View {
    let data: RocketsListItemViewData

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            RemoteImage(url: data.imageURL)
                .frame(width: DesignSystem.Size.rocketThumbnailWidth, height: DesignSystem.Size.rocketThumbnailHeight)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                Text(data.name)
                    .font(DesignSystem.Fonts.headline)
                    .foregroundStyle(DesignSystem.Colors.primaryText)
                Text(data.subtitle)
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                Text("rockets.listItem.successRate \(data.successRate)")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }
            .font(DesignSystem.Fonts.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, DesignSystem.Spacing.medium)

            Image(systemName: "chevron.right")
                .font(DesignSystem.Fonts.subheadline)
                .foregroundStyle(DesignSystem.Colors.tertiaryText)
                .padding(.trailing, DesignSystem.Spacing.medium)
                .accessibilityHidden(true)
        }
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("rockets.listItem.\(data.id)")
    }
}

#Preview("Light") {
    RocketListItemView(data: RocketsPreviewData.listItems[0])
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.background)
}

#Preview("Dark") {
    RocketListItemView(data: RocketsPreviewData.listItems[0])
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}

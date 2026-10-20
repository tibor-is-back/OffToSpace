import SwiftUI

enum LaunchDetailsViewEvent {
    case appeared
    case retryTapped
}

struct LaunchDetailsView: View {
    @State private var viewModel: LaunchDetailsViewModel
    private let onRocketSelected: (String) -> Void
    @State private var isWebcastPresented = false

    init(viewModel: LaunchDetailsViewModel, onRocketSelected: @escaping (String) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onRocketSelected = onRocketSelected
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Colors.background)
            .toolbar(.visible, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("launchDetails.screen")
            .onAppear {
                viewModel.handle(event: .appeared)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state.content {
        case .loading:
            ProgressView()
                .accessibilityIdentifier("launchDetails.loading")
        case .loaded(let data):
            details(data)
        case .error:
            ContentUnavailableView {
                Label("launches.details.errorTitle", systemImage: "exclamationmark.triangle")
            } description: {
                Text("launches.details.errorDescription")
            } actions: {
                Button("launches.details.retry") {
                    viewModel.handle(event: .retryTapped)
                }
                .buttonStyle(.primary)
                .accessibilityIdentifier("launchDetails.retry")
            }
            .accessibilityIdentifier("launchDetails.error")
        }
    }

    private func details(_ data: LaunchDetailsViewData) -> some View {
        ScrollView {
            VStack(spacing: .zero) {
                RemoteImage(url: data.imageURL)
                    .frame(height: DesignSystem.Size.launchDetailsImage)
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [.clear, DesignSystem.Colors.background],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: DesignSystem.Spacing.xLarge)
                    }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    title(data)
                    metadata(data.date, icon: "calendar", identifier: "launchDetails.date")
                    metadata(data.location, icon: "mappin.and.ellipse", identifier: "launchDetails.location")

                    if let webcastURL = data.webcastURL {
                        Button {
                            isWebcastPresented = true
                        } label: {
                            Label("launches.details.watchLaunch", systemImage: "play.fill")
                        }
                        .buttonStyle(.primary)
                        .accessibilityIdentifier("launchDetails.watchLaunch")
                        .sheet(isPresented: $isWebcastPresented) {
                            SafariView(url: webcastURL)
                                .ignoresSafeArea()
                        }
                    }

                    if let description = data.description {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("launches.details.description")
                                .font(DesignSystem.Fonts.title3)
                                .accessibilityAddTraits(.isHeader)
                            Text(description)
                                .foregroundStyle(DesignSystem.Colors.secondaryText)
                        }
                        .accessibilityIdentifier("launchDetails.description")
                    }

                    rocket(data.rocket)
                }
                .padding(DesignSystem.Spacing.large)
            }
        }
        .ignoresSafeArea(edges: .top)
        .font(DesignSystem.Fonts.body)
        .foregroundStyle(DesignSystem.Colors.primaryText)
    }

    private func title(_ data: LaunchDetailsViewData) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.small) {
                Text(data.name)
                    .font(DesignSystem.Fonts.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                BadgeView(text: data.statusText, style: data.statusStyle)
                    .fixedSize(horizontal: true, vertical: false)
            }
            if let subtitle = data.subtitle {
                Text(subtitle)
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }
        }
        .accessibilityIdentifier("launchDetails.title")
    }

    private func metadata(_ text: String, icon: String, identifier: String) -> some View {
        Label(text, systemImage: icon)
            .foregroundStyle(DesignSystem.Colors.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier(identifier)
    }

    private func rocket(_ data: LaunchDetailsViewData.Rocket) -> some View {
        Button {
            onRocketSelected(data.id)
        } label: {
            HStack(spacing: DesignSystem.Spacing.medium) {
                RemoteImage(url: data.imageURL)
                    .frame(width: DesignSystem.Size.image, height: DesignSystem.Size.image)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                    Text("launches.details.rocket")
                        .font(DesignSystem.Fonts.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                    Text(data.name)
                        .font(DesignSystem.Fonts.title3)
                    Text(data.type)
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .foregroundStyle(DesignSystem.Colors.tertiaryText)
                    .accessibilityHidden(true)
            }
            .padding(DesignSystem.Spacing.medium)
            .background(DesignSystem.Colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("launchDetails.rocket")
        .accessibilityHint("launches.details.rocketHint")
    }
}

#Preview("Full details") {
    NavigationStack {
        LaunchDetailsView(
            viewModel: LaunchesPreviewData.makeDetailsViewModel(launch: LaunchesPreviewData.detailsLaunch)
        ) { _ in }
    }
}

#Preview("Dark details") {
    NavigationStack {
        LaunchDetailsView(
            viewModel: LaunchesPreviewData.makeDetailsViewModel(launch: LaunchesPreviewData.detailsLaunch)
        ) { _ in }
    }
    .preferredColorScheme(.dark)
}

#Preview("Minimal details") {
    NavigationStack {
        LaunchDetailsView(
            viewModel: LaunchesPreviewData.makeDetailsViewModel(launch: LaunchesPreviewData.minimalDetailsLaunch)
        ) { _ in }
    }
}

#Preview("Error") {
    LaunchDetailsView(viewModel: LaunchesPreviewData.makeDetailsViewModel(state: .init(content: .error))) { _ in }
}

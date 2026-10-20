import SwiftUI

struct RocketDetailsView: View {
    @State private var viewModel: RocketDetailsViewModel

    init(viewModel: RocketDetailsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignSystem.Colors.background)
            .toolbar(.visible, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("rocketDetails.screen")
            .onAppear {
                viewModel.handle(event: .appeared)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .accessibilityIdentifier("rocketDetails.loading")
        case .loaded(let data):
            details(data)
        case .error:
            ContentUnavailableView {
                Label("rockets.details.errorTitle", systemImage: "exclamationmark.triangle")
            } description: {
                Text("rockets.details.errorDescription")
            } actions: {
                Button("rockets.details.retry") {
                    viewModel.handle(event: .retryTapped)
                }
                .buttonStyle(.primary)
                .accessibilityIdentifier("rocketDetails.retry")
            }
            .accessibilityIdentifier("rocketDetails.error")
        }
    }

    private func details(_ data: RocketDetailsViewData) -> some View {
        ScrollView {
            VStack(spacing: .zero) {
                RemoteImage(url: data.imageURL)
                    .frame(height: DesignSystem.Size.rocketDetailsImage)
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [.clear, DesignSystem.Colors.background],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: DesignSystem.Spacing.xLarge)
                    }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text(data.name)
                            .font(DesignSystem.Fonts.largeTitle)
                            .accessibilityAddTraits(.isHeader)
                        Text(data.subtitle)
                            .foregroundStyle(DesignSystem.Colors.secondaryText)
                    }
                    .accessibilityIdentifier("rocketDetails.title")

                    summary(data)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        Text("rockets.details.description")
                            .font(DesignSystem.Fonts.title3)
                            .accessibilityAddTraits(.isHeader)
                        Text(data.description)
                            .foregroundStyle(DesignSystem.Colors.secondaryText)
                    }
                    .accessibilityIdentifier("rocketDetails.description")

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        Text("rockets.details.technicalDetails")
                            .font(DesignSystem.Fonts.title3)
                            .accessibilityAddTraits(.isHeader)
                        technicalDetails(data)
                    }
                }
                .padding(DesignSystem.Spacing.large)
            }
        }
        .ignoresSafeArea(edges: .top)
        .font(DesignSystem.Fonts.body)
        .foregroundStyle(DesignSystem.Colors.primaryText)
    }

    private func summary(_ data: RocketDetailsViewData) -> some View {
        Grid(alignment: .leading, horizontalSpacing: DesignSystem.Spacing.large, verticalSpacing: DesignSystem.Spacing.medium) {
            GridRow {
                Text("rockets.details.status")
                HStack(spacing: DesignSystem.Spacing.small) {
                    Circle()
                        .fill(data.status == .active ? DesignSystem.Colors.successText : DesignSystem.Colors.secondaryText)
                        .frame(width: DesignSystem.Size.small, height: DesignSystem.Size.small)
                        .accessibilityHidden(true)
                    Text(data.status.text)
                }
                .accessibilityIdentifier("rocketDetails.status")
            }
            Divider()
            GridRow {
                Text("rockets.details.type")
                Text(data.type)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("rocketDetails.type")
            }
        }
        .foregroundStyle(DesignSystem.Colors.secondaryText)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
    }

    private func technicalDetails(_ data: RocketDetailsViewData) -> some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            technicalRow("rockets.details.engines", value: data.engines, icon: "flame", identifier: "rocketDetails.engines")
            Divider()
            technicalRow("rockets.details.engineType", value: data.engineType, icon: "gearshape", identifier: "rocketDetails.engineType")
            Divider()
            technicalRow("rockets.details.successRate", value: data.successRate, icon: "chart.line.uptrend.xyaxis",
                         identifier: "rocketDetails.successRate")
        }
        .foregroundStyle(DesignSystem.Colors.secondaryText)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
    }

    private func technicalRow(_ title: LocalizedStringKey, value: String, icon: String, identifier: String) -> some View {
        LabeledContent {
            Text(value)
                .multilineTextAlignment(.trailing)
        } label: {
            Label(title, systemImage: icon)
        }
        .accessibilityIdentifier(identifier)
    }
}

#Preview("Active") {
    NavigationStack {
        RocketDetailsView(viewModel: RocketsPreviewData.makeDetailsViewModel(state: .loaded(RocketsPreviewData.activeDetails)))
    }
}

#Preview("Dark active") {
    NavigationStack {
        RocketDetailsView(viewModel: RocketsPreviewData.makeDetailsViewModel(state: .loaded(RocketsPreviewData.activeDetails)))
    }
    .preferredColorScheme(.dark)
}

#Preview("Inactive without image") {
    NavigationStack {
        RocketDetailsView(viewModel: RocketsPreviewData.makeDetailsViewModel(state: .loaded(RocketsPreviewData.inactiveDetails)))
    }
}

#Preview("Loading") {
    NavigationStack {
        RocketDetailsView(viewModel: RocketsPreviewData.makeDetailsViewModel(state: .loading))
    }
}

#Preview("Error") {
    NavigationStack {
        RocketDetailsView(viewModel: RocketsPreviewData.makeDetailsViewModel(state: .error))
    }
}

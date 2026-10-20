import SwiftUI

struct LaunchesView: View {
    @State private var viewModel: LaunchesViewModel
    private let onLaunchSelected: (String) -> Void

    init(viewModel: LaunchesViewModel, onLaunchSelected: @escaping (String) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onLaunchSelected = onLaunchSelected
    }

    var body: some View {
        VStack(spacing: .zero) {
            header

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(DesignSystem.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.handle(event: .appeared)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("launches.launches.title")
                .font(DesignSystem.Fonts.largeTitle)
                .foregroundStyle(DesignSystem.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("launches.header")

            LaunchesDatePicker(
                startDate: viewModel.state.filter.startDate,
                endDate: viewModel.state.filter.endDate ?? .now
            ) { startDate, endDate in
                viewModel.handle(event: .dateRangeSelected(startDate: startDate, endDate: endDate))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.large)
        .padding(.top, DesignSystem.Spacing.xLarge)
        .padding(.bottom, DesignSystem.Spacing.medium)
        .background {
            Image("LaunchesHeader")
                .resizable()
                .scaledToFill()
                .clipped()
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [.clear, DesignSystem.Colors.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: DesignSystem.Spacing.xLarge)
                }
                .ignoresSafeArea(edges: .top)
        }
    }

    @ViewBuilder
    private func paginationFooter(_ pagination: LaunchesViewState.Pagination) -> some View {
        switch pagination {
        case .idle:
            Color.clear
                .frame(height: DesignSystem.Size.small)
                .onAppear {
                    viewModel.handle(event: .nextPageRequested)
                }
        case .loading:
            ProgressView()
                .accessibilityIdentifier("launches.paginationLoading")
        case .error:
            ContentUnavailableView {
                Label("launches.launches.errorTitle", systemImage: "exclamationmark.triangle")
            } actions: {
                Button("launches.launches.retry") {
                    viewModel.handle(event: .retryTapped)
                }
                .accessibilityIdentifier("launches.paginationRetry")
            }
            .accessibilityIdentifier("launches.paginationError")
        case .finished:
            EmptyView()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state.content {
        case .loading:
            ProgressView("launches.launches.loading")
                .accessibilityIdentifier("launches.loading")
        case .loaded(let launches, let pagination):
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(launches, id: \.id) { launch in
                        Button {
                            onLaunchSelected(launch.id)
                        } label: {
                            LaunchListItemView(data: launch)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("launches.launch.\(launch.id)")
                    }
                    paginationFooter(pagination)
                }
                .padding(DesignSystem.Spacing.medium)
            }
            .accessibilityIdentifier("launches.list")
        case .empty:
            ContentUnavailableView(
                "launches.launches.emptyTitle",
                systemImage: "sparkles",
                description: Text("launches.launches.emptyDescription")
            )
            .accessibilityIdentifier("launches.empty")
        case .error:
            ContentUnavailableView {
                Label("launches.launches.errorTitle", systemImage: "exclamationmark.triangle")
            } description: {
                Text("launches.launches.errorDescription")
            } actions: {
                Button("launches.launches.retry") {
                    viewModel.handle(event: .retryTapped)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.Colors.accent)
                .accessibilityIdentifier("launches.retry")
            }
            .accessibilityIdentifier("launches.error")
        }
    }
}

#Preview("Loading") {
    NavigationStack {
        LaunchesView(
            viewModel: LaunchesPreviewData.makeViewModel(content: .loading)
        ) { _ in }
    }
}

#Preview("Loaded") {
    NavigationStack {
        LaunchesView(
            viewModel: LaunchesPreviewData.makeViewModel(content: .loaded(LaunchesPreviewData.listItems))
        ) { _ in }
    }
}

#Preview("Empty") {
    NavigationStack {
        LaunchesView(
            viewModel: LaunchesPreviewData.makeViewModel(content: .empty)
        ) { _ in }
    }
}

#Preview("Error") {
    NavigationStack {
        LaunchesView(
            viewModel: LaunchesPreviewData.makeViewModel(content: .error)
        ) { _ in }
    }
}

#Preview("Dark Loaded") {
    NavigationStack {
        LaunchesView(
            viewModel: LaunchesPreviewData.makeViewModel(content: .loaded(LaunchesPreviewData.listItems))
        ) { _ in }
    }
    .preferredColorScheme(.dark)
}

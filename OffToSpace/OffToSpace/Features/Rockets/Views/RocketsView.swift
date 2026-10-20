import SwiftUI

struct RocketsView: View {
    @State private var viewModel: RocketsViewModel
    private let onRocketSelected: (String) -> Void

    init(viewModel: RocketsViewModel, onRocketSelected: @escaping (String) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onRocketSelected = onRocketSelected
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

    @ViewBuilder
    private var content: some View {
        switch viewModel.state.content {
        case .loading:
            ProgressView()
                .accessibilityIdentifier("rockets.loading")
        case .loaded(let items, let pagination):
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(items, id: \.id) { item in
                        Button {
                            onRocketSelected(item.id)
                        } label: {
                            RocketListItemView(data: item)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("rockets.rocket.\(item.id)")
                    }
                    paginationFooter(pagination)
                }
                .padding(DesignSystem.Spacing.medium)
            }
            .accessibilityIdentifier("rockets.list")
        case .empty:
            ContentUnavailableView(
                "rockets.rockets.emptyTitle",
                systemImage: "sparkles",
                description: Text("rockets.rockets.emptyDescription")
            )
            .accessibilityIdentifier("rockets.empty")
        case .error:
            errorContent
                .accessibilityIdentifier("rockets.error")
        }
    }

    @ViewBuilder
    private func paginationFooter(_ pagination: RocketsViewState.Pagination) -> some View {
        switch pagination {
        case .idle:
            Color.clear
                .frame(height: DesignSystem.Size.small)
                .onAppear {
                    viewModel.handle(event: .nextPageRequested)
                }
        case .loading:
            ProgressView()
                .accessibilityIdentifier("rockets.paginationLoading")
        case .error:
            errorContent
                .accessibilityIdentifier("rockets.paginationError")
        case .finished:
            EmptyView()
        }
    }

    private var errorContent: some View {
        ContentUnavailableView {
            Label("rockets.rockets.errorTitle", systemImage: "exclamationmark.triangle")
        } description: {
            Text("rockets.rockets.errorDescription")
        } actions: {
            Button("rockets.rockets.retry") {
                viewModel.handle(event: .retryTapped)
            }
            .buttonStyle(.primary)
            .accessibilityIdentifier("rockets.retry")
        }
    }

    private var header: some View {
        Text("rockets.rockets.title")
            .font(DesignSystem.Fonts.largeTitle)
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.top, DesignSystem.Spacing.xLarge)
            .padding(.bottom, DesignSystem.Spacing.medium)
            .background {
                Image("RocketsHeader")
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
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("rockets.header")
    }
}

#Preview("Light") {
    NavigationStack {
        RocketsView(
            viewModel: RocketsPreviewData.makeViewModel(state: .loaded(RocketsPreviewData.listItems, pagination: .finished))
        ) { _ in }
    }
}

#Preview("Dark") {
    NavigationStack {
        RocketsView(
            viewModel: RocketsPreviewData.makeViewModel(state: .loaded(RocketsPreviewData.listItems, pagination: .finished))
        ) { _ in }
    }
    .preferredColorScheme(.dark)
}

#Preview("Loading") {
    NavigationStack {
        RocketsView(viewModel: RocketsPreviewData.makeViewModel(state: .loading)) { _ in }
    }
}

#Preview("Empty") {
    NavigationStack {
        RocketsView(viewModel: RocketsPreviewData.makeViewModel(state: .empty)) { _ in }
    }
}

#Preview("Error") {
    NavigationStack {
        RocketsView(viewModel: RocketsPreviewData.makeViewModel(state: .error)) { _ in }
    }
}

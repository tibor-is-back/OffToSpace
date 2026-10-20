import Foundation
import Observation

struct RocketsViewState {
    var content: Content = .loading

    enum Content {
        case loading
        case loaded([RocketsListItemViewData], pagination: Pagination = .idle)
        case empty
        case error
    }

    enum Pagination {
        case idle
        case loading
        case error
        case finished
    }
}

enum RocketsViewEvent {
    case appeared
    case nextPageRequested
    case retryTapped
}

@Observable
final class RocketsViewModel {
    private(set) var state: RocketsViewState

    private let interactor: any RocketsInteractor
    private var items: [RocketsListItemViewData] = []
    private var loadingTask: Task<Void, Never>?

    init(interactor: any RocketsInteractor, state: RocketsViewState.Content = .loading) {
        self.interactor = interactor
        self.state = RocketsViewState(content: state)
        if case .loaded(let items, _) = state {
            self.items = items
        }
    }

    func handle(event: RocketsViewEvent) {
        switch event {
        case .appeared:
            guard case .loading = state.content else { return }
            loadNextPage()
        case .nextPageRequested, .retryTapped:
            loadNextPage()

        }
    }

    private func loadNextPage() {
        guard loadingTask == nil, interactor.hasNextPage else { return }
        state.content = items.isEmpty ? .loading : .loaded(items, pagination: .loading)

        loadingTask = Task { [weak self] in
            guard let self else { return }
            defer { loadingTask = nil }

            do {
                let rockets = try await interactor.loadNextPage()
                try Task.checkCancellation()
                map(rockets)
                state.content = items.isEmpty && !interactor.hasNextPage
                    ? .empty
                    : .loaded(items, pagination: interactor.hasNextPage ? .idle : .finished)
            } catch is CancellationError {
                // Cancellation does not represent a loading failure.
            } catch {
                guard !Task.isCancelled else { return }
                state.content = items.isEmpty ? .error : .loaded(items, pagination: .error)
            }
        }
    }

    private func map(_ rockets: [Rocket]) {
        for rocket in rockets {
            items.append(RocketsListItemViewData(
                id: rocket.id,
                name: rocket.name,
                subtitle: rocket.type,
                successRate: (Double(rocket.successRatePercent) / 100).formatted(.percent.precision(.fractionLength(0))),
                imageURL: rocket.imageURL
            ))
        }
    }
}

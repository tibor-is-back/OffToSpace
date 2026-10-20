import Foundation
import Observation

@Observable
final class RocketsViewModel {
    private(set) var state: RocketsViewState

    private let interactor: any RocketsInteractor
    private var items: [RocketsListItemViewData] = []
    private var loadingTask: Task<Void, Never>?

    init(interactor: any RocketsInteractor, state: RocketsViewState = .loading) {
        self.interactor = interactor
        self.state = state
        if case .loaded(let items, _) = state {
            self.items = items
        }
    }

    func handle(event: RocketsViewEvent) {
        switch event {
        case .appeared:
            guard case .loading = state else { return }
            loadNextPage()
        case .nextPageRequested, .retryTapped:
            loadNextPage()

        }
    }

    private func loadNextPage() {
        guard loadingTask == nil, interactor.hasNextPage else { return }
        state = items.isEmpty ? .loading : .loaded(items, pagination: .loading)

        loadingTask = Task { [weak self] in
            guard let self else { return }
            defer { loadingTask = nil }

            do {
                let rockets = try await interactor.loadNextPage()
                try Task.checkCancellation()
                map(rockets)
                state = items.isEmpty && !interactor.hasNextPage
                    ? .empty
                    : .loaded(items, pagination: interactor.hasNextPage ? .idle : .finished)
            } catch is CancellationError {
                // Cancellation does not represent a loading failure.
            } catch {
                guard !Task.isCancelled else { return }
                state = items.isEmpty ? .error : .loaded(items, pagination: .error)
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

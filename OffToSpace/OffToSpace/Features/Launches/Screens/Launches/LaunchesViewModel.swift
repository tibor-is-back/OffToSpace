import Foundation
import Observation

struct LaunchesViewState {
    var filter: LaunchFilter
    var content: Content = .loading

    enum Content {
        case loading
        case loaded([LaunchesListItemViewData], pagination: Pagination = .idle)
        case empty
        case error
    }

    enum Pagination: Hashable {
        case idle
        case loading
        case error
        case finished
    }
}

enum LaunchesViewEvent {
    case appeared
    case nextPageRequested
    case retryTapped
    case dateRangeSelected(startDate: Date, endDate: Date)
}

@Observable
final class LaunchesViewModel {
    private(set) var state: LaunchesViewState

    private let interactor: any LaunchesInteractor
    private var items: [LaunchesListItemViewData] = []
    private var loadingTask: Task<Void, Never>?

    init(interactor: any LaunchesInteractor, filter: LaunchFilter, content: LaunchesViewState.Content = .loading) {
        self.interactor = interactor
        state = LaunchesViewState(filter: filter, content: content)
        if case .loaded(let items, _) = content {
            self.items = items
        }
    }

    func handle(event: LaunchesViewEvent) {
        switch event {
        case .appeared:
            guard case .loading = state.content else { return }
            loadNextPage()
        case .nextPageRequested, .retryTapped:
            loadNextPage()
        case .dateRangeSelected(let startDate, let endDate):
            applyFilter(LaunchFilter(startDate: startDate, endDate: endDate))

        }
    }

    private func loadNextPage() {
        guard loadingTask == nil, interactor.hasNextPage else { return }

        state.content = items.isEmpty ? .loading : .loaded(items, pagination: .loading)

        loadingTask = Task { [weak self] in
            guard let self else { return }
            defer {
                if !Task.isCancelled {
                    loadingTask = nil
                }
            }

            do {
                let launches = try await interactor.loadNextPage()
                try Task.checkCancellation()

                map(launches)
                state.content = items.isEmpty && !interactor.hasNextPage
                    ? .empty
                    : .loaded(items, pagination: interactor.hasNextPage ? .idle : .finished)
            } catch is CancellationError {
                // A cancelled request must not replace the current filter's state.
            } catch {
                guard !Task.isCancelled else { return }
                state.content = items.isEmpty ? .error : .loaded(items, pagination: .error)
            }
        }
    }

    private func map(_ launches: [Launch]) {
        for launch in launches {
            items.append(LaunchesListItemViewData(launch: launch))
        }
    }

    private func applyFilter(_ filter: LaunchFilter) {
        loadingTask?.cancel()
        loadingTask = nil
        items.removeAll()
        state.filter = filter
        interactor.updateFilter(filter)
        loadNextPage()
    }
}

import Foundation
import Observation

enum RocketDetailsViewState {
    case loading
    case loaded(RocketDetailsViewData)
    case error
}

enum RocketDetailsViewEvent {
    case appeared
    case retryTapped
}

@Observable
final class RocketDetailsViewModel {
    private(set) var state: RocketDetailsViewState

    private let rocketID: String
    private let interactor: any RocketsInteractor
    private var loadingTask: Task<Void, Never>?

    init(rocketID: String, interactor: any RocketsInteractor, state: RocketDetailsViewState = .loading) {
        self.rocketID = rocketID
        self.interactor = interactor
        self.state = state
    }

    func handle(event: RocketDetailsViewEvent) {
        switch event {
        case .appeared:
            guard case .loading = state else { return }
            load()
        case .retryTapped:
            load()
        }
    }

    private func load() {
        guard loadingTask == nil else { return }
        state = .loading

        loadingTask = Task { [weak self] in
            guard let self else { return }
            defer { loadingTask = nil }

            do {
                let rocket = try await interactor.loadRocket(id: rocketID)
                try Task.checkCancellation()
                state = .loaded(map(rocket))
            } catch is CancellationError {
                // Cancellation does not represent a loading failure.
            } catch {
                guard !Task.isCancelled else { return }
                state = .error
            }
        }
    }

    private func map(_ rocket: Rocket) -> RocketDetailsViewData {
        RocketDetailsViewData(
            name: rocket.name,
            subtitle: String(localized: "rockets.details.subtitle"),
            imageURL: rocket.imageURL,
            status: rocket.isActive ? .active : .inactive,
            type: rocket.type,
            description: rocket.description,
            engines: rocket.engineCount.formatted(),
            engineType: rocket.engineType,
            successRate: (Double(rocket.successRatePercent) / 100).formatted(.percent.precision(.fractionLength(0)))
        )
    }
}

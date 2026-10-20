import Foundation

enum RocketsPreviewData {
    static func makeViewModel(state: RocketsViewState.Content) -> RocketsViewModel {
        RocketsViewModel(interactor: PreviewRocketsInteractor(), state: state)
    }

    static let listItems = [
        RocketsListItemViewData(
            id: "falcon-9", name: "Falcon 9", subtitle: "Orbital launch vehicle", successRate: "98%",
            imageURL: URL(string: "https://picsum.photos/seed/falcon9/200/300")
        ),
        RocketsListItemViewData(
            id: "falcon-heavy", name: "Falcon Heavy", subtitle: "Heavy lift launch vehicle", successRate: "100%",
            imageURL: URL(string: "https://picsum.photos/seed/falconheavy/200/300")
        ),
        RocketsListItemViewData(
            id: "starship", name: "Starship", subtitle: "Fully reusable launch vehicle", successRate: "0%",
            imageURL: nil
        )
    ]

    static func makeDetailsViewModel(rocketID: String) -> RocketDetailsViewModel {
        RocketDetailsViewModel(rocketID: rocketID, interactor: PreviewRocketsInteractor(), state: .loaded(activeDetails))
    }

    static func makeDetailsViewModel(state: RocketDetailsViewState) -> RocketDetailsViewModel {
        RocketDetailsViewModel(rocketID: "falcon-9", interactor: PreviewRocketsInteractor(), state: state)
    }

    static let activeDetails = RocketDetailsViewData(
        name: "Falcon 9",
        subtitle: "Orbital launch vehicle",
        imageURL: URL(string: "https://picsum.photos/seed/falcon9/800"),
        status: .active,
        type: "Two-stage orbital launch vehicle",
        description: "Falcon 9 is a two-stage, reusable orbital launch vehicle designed and manufactured by SpaceX. "
            + "It is capable of carrying a variety of payloads to low Earth orbit, geostationary transfer orbit, and beyond.",
        engines: "9 (first stage)",
        engineType: "Merlin 1D",
        successRate: "98% (247 / 252)"
    )

    static let inactiveDetails = RocketDetailsViewData(
        name: "Falcon 1",
        subtitle: "Orbital launch vehicle",
        imageURL: nil,
        status: .inactive,
        type: "Two-stage orbital launch vehicle",
        description: "Falcon 1 was a small orbital launch vehicle developed by SpaceX.",
        engines: "1 (first stage)",
        engineType: "Merlin",
        successRate: "40% (2 / 5)"
    )
}

private final class PreviewRocketsInteractor: RocketsInteractor {
    var hasNextPage: Bool { false }

    func loadNextPage() async throws -> [Rocket] { [] }

    func loadRocket(id: String) async throws -> Rocket {
        // Keep the preview in its supplied state.
        throw CancellationError()
    }
}

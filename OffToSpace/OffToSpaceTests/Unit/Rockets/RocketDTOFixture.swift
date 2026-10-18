import Foundation
@testable import OffToSpace

nonisolated enum RocketDTOFixture {
    static func make(
        id: String = "rocket-1",
        name: String = "Falcon 1",
        type: String = "rocket",
        description: String = "The Falcon 1 was an expendable launch system.",
        flickrImages: [String] = [
            "https://example.com/falcon-1-a.png",
            "https://example.com/falcon-1-b.png"
        ],
        successRatePct: Int = 40,
        active: Bool = false,
        engineCount: Int = 1,
        engineType: String = "merlin"
    ) -> RocketDTO {
        RocketDTO(
            id: id,
            name: name,
            type: type,
            description: description,
            flickrImages: flickrImages,
            successRatePct: successRatePct,
            active: active,
            engines: RocketDTO.Engines(number: engineCount, type: engineType)
        )
    }

    static func query(
        docs: [RocketDTO] = [make()],
        page: Int = 1,
        totalPages: Int = 2,
        hasNextPage: Bool = true
    ) -> RocketsQueryDTO {
        RocketsQueryDTO(
            docs: docs,
            page: page,
            totalPages: totalPages,
            hasNextPage: hasNextPage
        )
    }
}

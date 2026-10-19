import Foundation
@testable import OffToSpace

nonisolated enum LaunchDTOFixture {
    static let date = Date(timeIntervalSince1970: 1_143_235_800)

    static func make(
        id: String = "launch-1",
        name: String = "FalconSat",
        details: String? = "Engine failure at 33 seconds.",
        dateUtc: Date = date,
        upcoming: Bool = false,
        success: Bool? = false,
        largePatch: String? = "https://example.com/large.png",
        smallPatch: String? = "https://example.com/small.png",
        webcast: String? = "https://example.com/watch",
        rocketId: String = "rocket-1",
        rocketName: String = "Falcon 1",
        rocketType: String = "rocket",
        rocketFlickrImages: [String] = ["https://example.com/falcon-1-a.png"],
        launchpadName: String = "Kwajalein Atoll",
        launchpadFullName: String = "Kwajalein Atoll Omelek Island"
    ) -> LaunchDTO {
        LaunchDTO(
            id: id,
            name: name,
            details: details,
            dateUtc: dateUtc,
            upcoming: upcoming,
            success: success,
            links: LaunchDTO.Links(
                patch: LaunchDTO.Links.Patch(small: smallPatch, large: largePatch),
                webcast: webcast
            ),
            rocket: LaunchDTO.Rocket(
                id: rocketId,
                name: rocketName,
                type: rocketType,
                flickrImages: rocketFlickrImages
            ),
            launchpad: LaunchDTO.Launchpad(
                id: "pad-1",
                name: launchpadName,
                fullName: launchpadFullName
            )
        )
    }

    static func query(
        docs: [LaunchDTO] = [make()],
        page: Int = 1,
        totalPages: Int = 3,
        hasNextPage: Bool = true
    ) -> LaunchesQueryDTO {
        LaunchesQueryDTO(
            docs: docs,
            page: page,
            totalPages: totalPages,
            hasNextPage: hasNextPage
        )
    }
}

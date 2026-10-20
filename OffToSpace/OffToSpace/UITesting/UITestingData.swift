import Foundation

nonisolated enum UITestingData {
    static let launchDate = Date(timeIntervalSince1970: 1_709_506_380)
    static let imageURL = Bundle.main.url(forResource: "UITestingRocket", withExtension: "png")

    static let rockets = [
        Rocket(
            id: "falcon-1", name: "Falcon 1", type: "Small orbital launch vehicle",
            description: "A two-stage launch vehicle that pioneered privately developed orbital flight.",
            imageURL: nil, successRatePercent: 40, isActive: false, engineCount: 1, engineType: "Merlin"
        ),
        Rocket(
            id: "falcon-heavy", name: "Falcon Heavy", type: "Heavy lift launch vehicle",
            description: "Three boosters provide lift for heavy payloads and deep-space missions.",
            imageURL: nil, successRatePercent: 100, isActive: true, engineCount: 27, engineType: "Merlin"
        ),
        Rocket(
            id: "falcon-9", name: "Falcon 9", type: "Orbital launch vehicle",
            description: "A reusable two-stage rocket.",
            imageURL: imageURL, successRatePercent: 98, isActive: true, engineCount: 9, engineType: "Merlin"
        )
    ]

    static let launches: [Launch] = {
        let missions: [Mission] = [
            Mission(id: "starlink-6-40", name: "Starlink Group 6-40", status: .successful),
            Mission(id: "pace", name: "PACE", status: .successful),
            Mission(id: "im-1", name: "IM-1", status: .successful),
            Mission(id: "transport-10", name: "Transporter-10", status: .successful),
            Mission(id: "test-flight", name: "Orbital Test Flight", status: .failed),
            Mission(id: "crs-30", name: "CRS-30", status: .successful),
            Mission(id: "bandwagon-1", name: "Bandwagon-1", status: .successful),
            Mission(id: "classified", name: "Classified Payload", status: .unknown),
            Mission(id: "starlink-6-41", name: "Starlink Group 6-41", status: .successful),
            Mission(id: "europa-clipper", name: "Europa Clipper", status: .upcoming),
            Mission(id: "polaris-dawn", name: "Polaris Dawn", status: .upcoming),
            Mission(id: "crew-8", name: "Crew-8", status: .successful)
        ]
        return missions.enumerated().map { index, mission in
            let rocket = rockets[mission.id == "europa-clipper" ? 1 : 2]
            return Launch(
                id: mission.id,
                name: mission.name,
                details: mission.id == "classified" ? nil : "A mission carrying crew or payloads to orbit and beyond.",
                imageURL: index.isMultiple(of: 2) || mission.id == "crew-8" ? imageURL : nil,
                launchSite: "KSC LC-39A",
                launchSiteFullName: "Kennedy Space Center Launch Complex 39A",
                date: launchDate.addingTimeInterval(Double(index) * 86_400),
                status: mission.status,
                webcastURL: nil,
                rocket: .init(id: rocket.id, name: rocket.name, type: rocket.type, imageURL: rocket.imageURL)
            )
        }
    }()

    private struct Mission {
        let id: String
        let name: String
        let status: Launch.Status
    }

    static func page<Item: Sendable>(of items: [Item], page: Int, limit: Int) -> Page<Item> {
        precondition(page > 0 && limit > 0)
        let start = min((page - 1) * limit, items.count)
        let end = min(start + limit, items.count)
        return Page(
            items: Array(items[start..<end]),
            page: page,
            totalPages: (items.count + limit - 1) / limit,
            hasNextPage: end < items.count
        )
    }
}

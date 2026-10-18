import Foundation

nonisolated struct LaunchDTO: Decodable, Sendable {
    let id: String
    let name: String
    let details: String?
    let dateUtc: Date
    let upcoming: Bool
    let success: Bool?
    let links: Links
    let rocket: Rocket
    let launchpad: Launchpad

    nonisolated struct Rocket: Decodable, Sendable {
        let id: String
        let name: String
        let type: String
    }

    nonisolated struct Launchpad: Decodable, Sendable {
        let id: String
        let name: String
        let fullName: String

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case fullName = "full_name"
        }
    }

    nonisolated struct Links: Decodable, Sendable {
        let patch: Patch
        let webcast: String?

        nonisolated struct Patch: Decodable, Sendable {
            let small: String?
            let large: String?
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case details
        case dateUtc = "date_utc"
        case upcoming
        case success
        case links
        case rocket
        case launchpad
    }
}

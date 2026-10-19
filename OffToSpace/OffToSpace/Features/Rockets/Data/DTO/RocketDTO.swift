import Foundation

nonisolated struct RocketDTO: Decodable {
    let id: String
    let name: String
    let type: String
    let description: String
    let flickrImages: [String]
    let successRatePct: Int
    let active: Bool
    let engines: Engines

    nonisolated struct Engines: Decodable {
        let number: Int
        let type: String
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case description
        case flickrImages = "flickr_images"
        case successRatePct = "success_rate_pct"
        case active
        case engines
    }
}

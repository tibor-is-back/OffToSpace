import Foundation

nonisolated struct RocketsQueryDTO: Decodable {
    let docs: [RocketDTO]
    let page: Int
    let totalPages: Int
    let hasNextPage: Bool
}

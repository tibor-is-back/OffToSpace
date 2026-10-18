import Foundation

nonisolated struct LaunchesQueryDTO: Decodable, Sendable {
    let docs: [LaunchDTO]
    let page: Int
    let totalPages: Int
    let hasNextPage: Bool
}

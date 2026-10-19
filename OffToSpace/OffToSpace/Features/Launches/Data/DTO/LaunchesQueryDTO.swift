import Foundation

nonisolated struct LaunchesQueryDTO: Decodable {
    let docs: [LaunchDTO]
    let page: Int
    let totalPages: Int
    let hasNextPage: Bool
}

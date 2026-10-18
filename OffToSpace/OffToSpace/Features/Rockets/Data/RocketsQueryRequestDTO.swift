import Foundation

nonisolated struct RocketsQueryRequestDTO: Encodable {
    private struct Query: Encodable {}

    private struct Options: Encodable {
        let page: Int
        let limit: Int
        let sort: [String: String]
    }

    private static let firstFlightKey = "first_flight"
    private static let ascendingSort = "asc"

    private let query: Query
    private let options: Options

    init(page: Int, limit: Int) {
        query = Query()
        options = Options(
            page: page,
            limit: limit,
            sort: [Self.firstFlightKey: Self.ascendingSort]
        )
    }
}

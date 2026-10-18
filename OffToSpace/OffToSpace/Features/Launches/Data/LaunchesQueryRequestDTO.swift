import Foundation

nonisolated struct LaunchesQueryRequestDTO: Encodable, Sendable {
    private struct DateIntervalQuery: Encodable, Sendable {
        let gte: Date
        let lte: Date?

        enum CodingKeys: String, CodingKey {
            case gte = "$gte"
            case lte = "$lte"
        }
    }

    private struct Query: Encodable, Sendable {
        let dateUtc: DateIntervalQuery

        enum CodingKeys: String, CodingKey {
            case dateUtc = "date_utc"
        }
    }

    private struct Options: Encodable, Sendable {
        let page: Int
        let limit: Int
        let sort: [String: String]
        let populate: [String]
    }

    private static let dateUtcKey = "date_utc"
    private static let descendingSort = "desc"
    private static let rocketPopulatePath = "rocket"
    private static let launchpadPopulatePath = "launchpad"

    private let query: Query
    private let options: Options

    init(page: Int, limit: Int, startDate: Date, endDate: Date?) {
        query = Query(
            dateUtc: DateIntervalQuery(gte: startDate, lte: endDate)
        )
        options = Options(
            page: page,
            limit: limit,
            sort: [Self.dateUtcKey: Self.descendingSort],
            populate: [Self.rocketPopulatePath, Self.launchpadPopulatePath]
        )
    }
}

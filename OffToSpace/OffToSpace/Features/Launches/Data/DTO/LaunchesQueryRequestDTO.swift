import Foundation

nonisolated struct LaunchesQueryRequestDTO: Encodable {
    private struct DateIntervalQuery: Encodable {
        let gte: Date
        let lte: Date?

        enum CodingKeys: String, CodingKey {
            case gte = "$gte"
            case lte = "$lte"
        }
    }

    private struct Query: Encodable {
        let dateUtc: DateIntervalQuery

        enum CodingKeys: String, CodingKey {
            case dateUtc = "date_utc"
        }
    }

    private struct Options: Encodable {
        let page: Int
        let limit: Int
        let sort: [String: String]
        let populate: [Populate]
    }

    private struct Populate: Encodable {
        let path: String
        let select: [String: Int]?

        enum CodingKeys: String, CodingKey {
            case path
            case select
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(path, forKey: .path)
            try container.encodeIfPresent(select, forKey: .select)
        }
    }

    private static let dateUtcKey = "date_utc"
    private static let descendingSort = "desc"
    private static let rocketPopulatePath = "rocket"
    private static let launchpadPopulatePath = "launchpad"
    private static let rocketNameField = "name"
    private static let rocketTypeField = "type"
    private static let rocketFlickrImagesField = "flickr_images"
    private static let includeField = 1

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
            populate: [
                Populate(
                    path: Self.rocketPopulatePath,
                    select: [
                        Self.rocketNameField: Self.includeField,
                        Self.rocketTypeField: Self.includeField,
                        Self.rocketFlickrImagesField: Self.includeField
                    ]
                ),
                Populate(path: Self.launchpadPopulatePath, select: nil)
            ]
        )
    }
}

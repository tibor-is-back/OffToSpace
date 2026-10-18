import Foundation

nonisolated enum RocketsEndpoint {
    case rocketsQuery(page: Int, limit: Int)
    case rocket(id: String)

    private static let versionPath = "v4"
    private static let rocketsPath = "rockets"
    private static let queryPath = "query"
    private static let postMethod = "POST"
    private static let jsonContentType = "application/json"
    private static let contentTypeHeader = "Content-Type"

    func urlRequest(baseURL: URL) throws -> URLRequest {
        switch self {
        case let .rocketsQuery(page, limit):
            let url = baseURL
                .appending(path: Self.versionPath)
                .appending(path: Self.rocketsPath)
                .appending(path: Self.queryPath)
            var request = URLRequest(url: url)
            request.httpMethod = Self.postMethod
            request.setValue(Self.jsonContentType, forHTTPHeaderField: Self.contentTypeHeader)
            request.httpBody = try JSONEncoder().encode(
                RocketsQueryRequestDTO(page: page, limit: limit)
            )
            return request
        case let .rocket(id):
            let url = baseURL
                .appending(path: Self.versionPath)
                .appending(path: Self.rocketsPath)
                .appending(path: id)
            return URLRequest(url: url)
        }
    }
}

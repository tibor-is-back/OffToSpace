import Foundation

nonisolated final class DefaultAPIClient: APIClient {
    private static let successStatusCodes = 200..<300

    private let session: URLSession
    nonisolated(unsafe) private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func request<Response: Decodable & Sendable>(_ urlRequest: URLRequest) async throws -> Response {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as CancellationError {
            throw error
        } catch let error as URLError {
            throw map(error)
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard Self.successStatusCodes.contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch is DecodingError {
            throw NetworkError.decodingFailed
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    private func map(_ urlError: URLError) -> Error {
        switch urlError.code {
        case .cancelled:
            CancellationError()
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            NetworkError.noConnection
        case .timedOut:
            NetworkError.timeout
        default:
            NetworkError.unknown(urlError)
        }
    }
}

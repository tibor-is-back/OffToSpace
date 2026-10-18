import Foundation

nonisolated enum NetworkError: Error, Sendable {
    case noConnection
    case timeout
    case invalidResponse
    case serverError
    case decodingFailed
    case unknown(any Error)
}

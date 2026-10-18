import XCTest
@testable import OffToSpace

final class DefaultRocketsRepositoryTests: XCTestCase {
    func testMapsQueryResponseToRocketPage() async throws {
        // Given
        let dto = RocketDTOFixture.query(
            docs: [
                RocketDTOFixture.make(id: "rocket-1", name: "Falcon 1", active: false),
                RocketDTOFixture.make(id: "rocket-2", name: "Falcon 9", active: true)
            ],
            page: 1,
            totalPages: 2,
            hasNextPage: true
        )
        let repository = DefaultRocketsRepository(
            apiClient: APIClientStub(returning: dto),
            baseURL: try XCTUnwrap(URL(string: "https://api.example.com"))
        )

        // When
        let page = try await repository.fetchRockets(page: 1, limit: 10)

        // Then
        XCTAssertEqual(page, RocketsPageMapper.map(dto))
    }

    func testMapsRocketDetailsResponse() async throws {
        // Given
        let dto = RocketDTOFixture.make(id: "rocket-1", name: "Falcon 9", active: true)
        let repository = DefaultRocketsRepository(
            apiClient: APIClientStub(returning: dto),
            baseURL: try XCTUnwrap(URL(string: "https://api.example.com"))
        )

        // When
        let rocket = try await repository.fetchRocket(id: "rocket-1")

        // Then
        XCTAssertEqual(rocket, RocketMapper.map(dto))
    }

    func testPropagatesNoConnection() async {
        // Given
        let repository = makeRepository(throwing: .noConnection)

        // When
        let error = await fetchError(from: repository)

        // Then
        assertNetworkError(error, equals: .noConnection)
    }

    func testPropagatesTimeout() async {
        // Given
        let repository = makeRepository(throwing: .timeout)

        // When
        let error = await fetchError(from: repository)

        // Then
        assertNetworkError(error, equals: .timeout)
    }

    func testPropagatesServerError() async {
        // Given
        let repository = makeRepository(throwing: .serverError)

        // When
        let error = await fetchError(from: repository)

        // Then
        assertNetworkError(error, equals: .serverError)
    }

    func testPropagatesDecodingFailed() async {
        // Given
        let repository = makeRepository(throwing: .decodingFailed)

        // When
        let error = await fetchError(from: repository)

        // Then
        assertNetworkError(error, equals: .decodingFailed)
    }

    func testFetchRocketPropagatesServerError() async {
        // Given
        let repository = makeRepository(throwing: .serverError)

        // When
        let error = await fetchRocketError(from: repository)

        // Then
        assertNetworkError(error, equals: .serverError)
    }

    private func makeRepository(throwing error: NetworkError) -> DefaultRocketsRepository {
        DefaultRocketsRepository(
            apiClient: APIClientStub(throwing: error),
            baseURL: URL(string: "https://api.example.com")!
        )
    }

    private func fetchError(from repository: DefaultRocketsRepository) async -> NetworkError? {
        do {
            _ = try await repository.fetchRockets(page: 1, limit: 10)
            return nil
        } catch let error as NetworkError {
            return error
        } catch {
            XCTFail("Unexpected error \(error)")
            return nil
        }
    }

    private func fetchRocketError(from repository: DefaultRocketsRepository) async -> NetworkError? {
        do {
            _ = try await repository.fetchRocket(id: "rocket-1")
            return nil
        } catch let error as NetworkError {
            return error
        } catch {
            XCTFail("Unexpected error \(error)")
            return nil
        }
    }

    private func assertNetworkError(
        _ error: NetworkError?,
        equals expected: NetworkError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch (error, expected) {
        case (.noConnection, .noConnection),
             (.timeout, .timeout),
             (.invalidResponse, .invalidResponse),
             (.serverError, .serverError),
             (.decodingFailed, .decodingFailed):
            return
        default:
            XCTFail("Expected \(expected), got \(String(describing: error))", file: file, line: line)
        }
    }
}

nonisolated private final class APIClientStub: APIClient {
    private let value: (any Sendable)?
    private let error: NetworkError?

    init(returning value: any Sendable) {
        self.value = value
        self.error = nil
    }

    init(throwing error: NetworkError) {
        self.value = nil
        self.error = error
    }

    func request<Response: Decodable & Sendable>(_ urlRequest: URLRequest) async throws -> Response {
        if let error {
            throw error
        }

        guard let value, let response = value as? Response else {
            throw NetworkError.decodingFailed
        }

        return response
    }
}

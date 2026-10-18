import XCTest
@testable import OffToSpace

final class DefaultLaunchesRepositoryTests: XCTestCase {
    func testMapsQueryResponseToLaunchPage() async throws {
        // Given
        let dto = LaunchDTOFixture.query(
            docs: [
                LaunchDTOFixture.make(id: "launch-1", name: "FalconSat", success: false),
                LaunchDTOFixture.make(id: "launch-2", name: "DemoSat", success: true)
            ],
            page: 1,
            totalPages: 4,
            hasNextPage: true
        )
        let repository = DefaultLaunchesRepository(
            apiClient: APIClientStub(returning: dto),
            baseURL: try XCTUnwrap(URL(string: "https://api.example.com"))
        )

        // When
        let page = try await repository.fetchLaunches(
            page: 1,
            limit: 10,
            startDate: LaunchDTOFixture.date
        )

        // Then
        XCTAssertEqual(page, LaunchesPageMapper.map(dto))
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

    private func makeRepository(throwing error: NetworkError) -> DefaultLaunchesRepository {
        DefaultLaunchesRepository(
            apiClient: APIClientStub(throwing: error),
            baseURL: URL(string: "https://api.example.com")!
        )
    }

    private func fetchError(from repository: DefaultLaunchesRepository) async -> NetworkError? {
        do {
            _ = try await repository.fetchLaunches(
                page: 1,
                limit: 10,
                startDate: LaunchDTOFixture.date
            )
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
    private let dto: LaunchesQueryDTO?
    private let error: NetworkError?

    init(returning dto: LaunchesQueryDTO) {
        self.dto = dto
        self.error = nil
    }

    init(throwing error: NetworkError) {
        self.dto = nil
        self.error = error
    }

    func request<Response: Decodable & Sendable>(_ urlRequest: URLRequest) async throws -> Response {
        if let error {
            throw error
        }

        guard let dto, let response = dto as? Response else {
            throw NetworkError.decodingFailed
        }

        return response
    }
}

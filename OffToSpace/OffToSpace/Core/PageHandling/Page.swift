nonisolated struct Page<Item: Sendable>: Sendable {
    let items: [Item]
    let page: Int
    let totalPages: Int
    let hasNextPage: Bool
}

extension Page: Equatable where Item: Equatable {}

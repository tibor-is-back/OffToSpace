struct PageHandler {
    let limit: Int
    private(set) var nextPage: Int? = 1

    mutating func advance(page: Int, hasNextPage: Bool) {
        nextPage = hasNextPage ? page + 1 : nil
    }

    mutating func reset() {
        nextPage = 1
    }
}

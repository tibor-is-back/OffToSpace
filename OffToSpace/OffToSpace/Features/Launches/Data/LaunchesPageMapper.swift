nonisolated enum LaunchesPageMapper {
    static func map(_ dto: LaunchesQueryDTO) -> Page<Launch> {
        Page(
            items: dto.docs.map(LaunchMapper.map),
            page: dto.page,
            totalPages: dto.totalPages,
            hasNextPage: dto.hasNextPage
        )
    }
}

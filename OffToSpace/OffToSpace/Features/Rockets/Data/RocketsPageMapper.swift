nonisolated enum RocketsPageMapper {
    static func map(_ dto: RocketsQueryDTO) -> Page<Rocket> {
        Page(
            items: dto.docs.map(RocketMapper.map),
            page: dto.page,
            totalPages: dto.totalPages,
            hasNextPage: dto.hasNextPage
        )
    }
}

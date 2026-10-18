import Foundation

nonisolated enum RocketMapper {
    static func map(_ dto: RocketDTO) -> Rocket {
        Rocket(
            id: dto.id,
            name: dto.name,
            type: dto.type,
            description: dto.description,
            imageURL: dto.flickrImages.compactMap(URL.init(string:)).first,
            successRatePercent: dto.successRatePct,
            isActive: dto.active,
            engineCount: dto.engines.number,
            engineType: dto.engines.type
        )
    }
}

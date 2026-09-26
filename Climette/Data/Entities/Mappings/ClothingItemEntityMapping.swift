import Foundation

extension ClothingItemEntity {
    @MainActor public func toDomain() -> Garment {
        let archetype = GarmentArchetype(
            id: archetypeId,
            canonicalName: canonicalName,
            bodyZone: BodyZone(rawValue: bodyZoneRaw) ?? .upperTorso,
            supportedLayer: layerRaw != nil ? ClothingLayer(rawValue: layerRaw!) : nil,
            baseProtection: EnvironmentalProtection(thermal: baseThermal, wind: baseWind, water: baseWater)
        )
        
        return Garment(
            id: id,
            archetype: archetype,
            userNickname: userNickname,
            color: color,
            isAvailable: isAvailable,
            overrideThermal: overrideThermal,
            overrideWind: overrideWind,
            overrideWater: overrideWater
        )
    }
    
    public convenience init(from domain: Garment) {
        self.init(
            id: domain.id,
            archetypeId: domain.archetype.id,
            canonicalName: domain.archetype.canonicalName,
            bodyZoneRaw: domain.archetype.bodyZone.rawValue,
            layerRaw: domain.archetype.supportedLayer?.rawValue,
            baseThermal: domain.archetype.baseProtection.thermal,
            baseWind: domain.archetype.baseProtection.wind,
            baseWater: domain.archetype.baseProtection.water,
            userNickname: domain.userNickname,
            color: domain.color,
            isAvailable: domain.isAvailable,
            overrideThermal: domain.overrideThermal,
            overrideWind: domain.overrideWind,
            overrideWater: domain.overrideWater
        )
    }
}

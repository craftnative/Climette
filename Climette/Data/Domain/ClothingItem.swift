import Foundation

public enum BodyZone: String, Codable, CaseIterable, Sendable {
    case headNeck = "Cabeza / Cuello"
    case upperTorso = "Torso superior"
    case lowerBody = "Piernas / Inferior"
    case feet = "Pies"
    case hands = "Manos"
    case accessories = "Complementos / Accesorios"
}

public enum ClothingLayer: String, Codable, CaseIterable, Sendable {
    case base = "Capa Base"
    case mid = "Capa Intermedia"
    case outer = "Capa Exterior"
}

public struct EnvironmentalProtection: Codable, Sendable, Equatable {
    public var thermal: Int
    public var wind: Int
    public var water: Int

    public init(thermal: Int, wind: Int, water: Int) {
        self.thermal = max(1, min(10, thermal))
        self.wind = max(1, min(10, wind))
        self.water = max(1, min(10, water))
    }
}

public struct GarmentArchetype: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let canonicalName: String
    public let bodyZone: BodyZone
    public let supportedLayer: ClothingLayer?
    public let baseProtection: EnvironmentalProtection
    
    public init(id: String, canonicalName: String, bodyZone: BodyZone, supportedLayer: ClothingLayer? = nil, baseProtection: EnvironmentalProtection) {
        self.id = id
        self.canonicalName = canonicalName
        self.bodyZone = bodyZone
        self.supportedLayer = supportedLayer
        self.baseProtection = baseProtection
    }
}

public struct Garment: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let archetype: GarmentArchetype
    public var userNickname: String?
    public var color: String?
    public var isAvailable: Bool
    
    public var overrideThermal: Int?
    public var overrideWind: Int?
    public var overrideWater: Int?

    public var resolvedDisplayName: String {
        if let nickname = userNickname, !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nickname
        }
        return archetype.canonicalName
    }
    
    public var effectiveProtection: EnvironmentalProtection {
        EnvironmentalProtection(
            thermal: overrideThermal ?? archetype.baseProtection.thermal,
            wind: overrideWind ?? archetype.baseProtection.wind,
            water: overrideWater ?? archetype.baseProtection.water
        )
    }

    public init(
        id: UUID = UUID(),
        archetype: GarmentArchetype,
        userNickname: String? = nil,
        color: String? = nil,
        isAvailable: Bool = true,
        overrideThermal: Int? = nil,
        overrideWind: Int? = nil,
        overrideWater: Int? = nil
    ) {
        self.id = id
        self.archetype = archetype
        self.userNickname = userNickname
        self.color = color
        self.isAvailable = isAvailable
        self.overrideThermal = overrideThermal
        self.overrideWind = overrideWind
        self.overrideWater = overrideWater
    }
}

public struct Outfit: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public var garments: [Garment]

    public var garmentsByZone: [BodyZone: [Garment]] {
        Dictionary(grouping: garments, by: { $0.archetype.bodyZone })
    }

    public var summaryDescription: String {
        garments.map { "[\($0.resolvedDisplayName)]" }.joined(separator: " + ")
    }

    public init(id: UUID = UUID(), garments: [Garment] = []) {
        self.id = id
        self.garments = garments
    }
    
    public func protection(for zone: BodyZone) -> EnvironmentalProtection {
        let zoneGarments = garmentsByZone[zone] ?? []
        let thermal = zoneGarments.map { $0.effectiveProtection.thermal }.reduce(0, +)
        let wind = zoneGarments.map { $0.effectiveProtection.wind }.reduce(0, +)
        let water = zoneGarments.map { $0.effectiveProtection.water }.reduce(0, +)
        
        return EnvironmentalProtection(
            thermal: min(10, thermal),
            wind: min(10, wind),
            water: min(10, water)
        )
    }
    
    public func globalProtection() -> EnvironmentalProtection {
        let allThermal = garments.map { $0.effectiveProtection.thermal }.reduce(0, +)
        let allWind = garments.map { $0.effectiveProtection.wind }.reduce(0, +)
        let allWater = garments.map { $0.effectiveProtection.water }.reduce(0, +)
        
        return EnvironmentalProtection(
            thermal: min(10, allThermal),
            wind: min(10, allWind),
            water: min(10, allWater)
        )
    }
}

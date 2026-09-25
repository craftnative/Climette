import Foundation

public enum ThermalPerception: String, Codable, CaseIterable, Sendable {
    case perfect = "Clavada / Perfecto"
    case feltCold = "Pasé frío"
    case feltHot = "Pasé calor"
}

public enum PhysicalReaction: String, Codable, Sendable {
    case enduredAsIs = "Aguanté con lo puesto"
    case adjustedClothing = "Me añadí/quité ropa"
}

public enum PostAdjustmentState: String, Codable, Sendable {
    case stabilized = "Estuve perfecto"
    case stillUncomfortable = "Seguí destemplado"
}

public enum DailyCollectionState: String, Codable, CaseIterable, Sendable {
    case correct = "Correcto"
    case adjusted = "Ajustado"
    case ignored = "Ignorado"
    case deleted = "Borrado"
}

public struct FeedbackRecord: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let weatherSnapshot: Weather
    public let originPriority: RecommendationPriority
    public let evaluatedPeriod: DayEvaluationPeriod?
    public let wornOutfit: Outfit
    public let perception: ThermalPerception
    public let isIndoorDistortion: Bool
    public let physicalReaction: PhysicalReaction?
    public let adjustedGarment: Garment?
    public let isGarmentAddition: Bool?
    public let postAdjustmentState: PostAdjustmentState?
    public var collectionState: DailyCollectionState

    public var resolvesAsSuccess: Bool {
        if collectionState == .deleted || collectionState == .ignored { return false }
        if isIndoorDistortion { return false }
        if perception == .perfect { return true }
        if physicalReaction == .adjustedClothing && postAdjustmentState == .stabilized {
            return true
        }
        return false
    }

    public init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        weatherSnapshot: Weather,
        originPriority: RecommendationPriority,
        evaluatedPeriod: DayEvaluationPeriod? = nil,
        wornOutfit: Outfit,
        perception: ThermalPerception,
        isIndoorDistortion: Bool = false,
        physicalReaction: PhysicalReaction? = nil,
        adjustedGarment: Garment? = nil,
        isGarmentAddition: Bool? = nil,
        postAdjustmentState: PostAdjustmentState? = nil,
        collectionState: DailyCollectionState = .correct
    ) {
        self.id = id
        self.timestamp = timestamp
        self.weatherSnapshot = weatherSnapshot
        self.originPriority = originPriority
        self.evaluatedPeriod = evaluatedPeriod
        self.wornOutfit = wornOutfit
        self.perception = perception
        self.isIndoorDistortion = isIndoorDistortion
        self.physicalReaction = physicalReaction
        self.adjustedGarment = adjustedGarment
        self.isGarmentAddition = isGarmentAddition
        self.postAdjustmentState = postAdjustmentState
        self.collectionState = collectionState
    }
}

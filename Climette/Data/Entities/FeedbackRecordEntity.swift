import Foundation
import SwiftData

public enum RecommendationState: String, Sendable {
    case correct = "Correcto"
    case incorrect = "Incorrecto"
    case adjusted = "Incorrecto pero ajustado"
}

@Model
public final class FeedbackRecordEntity {
    public var id: UUID = UUID()
    public var timestamp: Date = Date()
    
    @Relationship(inverse: \WeatherSnapshotEntity.feedbackRecord)
    public var weatherSnapshot: WeatherSnapshotEntity?
    
    public var originPriorityRaw: Int = 0
    public var evaluatedPeriodRaw: String?
    
    @Relationship
    public var recommendedGarments: [ClothingItemEntity]?
    
    @Relationship
    public var wornGarments: [ClothingItemEntity]?
    
    public var perceptionRaw: String = ""
    public var isIndoorDistortion: Bool = false
    public var affectedZoneRaw: String?
    public var physicalReactionRaw: String?
    
    @Relationship
    public var adjustedGarment: ClothingItemEntity?
    
    public var postAdjustmentStateRaw: String?
    public var collectionStateRaw: String = ""

    public var recommendationState: RecommendationState {
        if collectionStateRaw == "Ajustado" || adjustedGarment != nil || physicalReactionRaw == PhysicalReaction.adjustedClothing.rawValue {
            return .adjusted
        }
        if collectionStateRaw == "Incorrecto" || perceptionRaw == ThermalPerception.feltCold.rawValue || perceptionRaw == ThermalPerception.feltHot.rawValue {
            return .incorrect
        }
        return .correct
    }

    public var addedGarments: [ClothingItemEntity] {
        guard let recommended = recommendedGarments, !recommended.isEmpty else { return [] }
        let recommendedIDs = Set(recommended.map(\.id))
        return (wornGarments ?? []).filter { !recommendedIDs.contains($0.id) }
    }

    public var removedGarments: [ClothingItemEntity] {
        guard let recommended = recommendedGarments, !recommended.isEmpty else { return [] }
        let wornIDs = Set((wornGarments ?? []).map(\.id))
        return recommended.filter { !wornIDs.contains($0.id) }
    }

    public var keptGarments: [ClothingItemEntity] {
        guard let recommended = recommendedGarments, !recommended.isEmpty else { return wornGarments ?? [] }
        let recommendedIDs = Set(recommended.map(\.id))
        return (wornGarments ?? []).filter { recommendedIDs.contains($0.id) }
    }

    public init(
        id: UUID = UUID(),
        timestamp: Date,
        weatherSnapshot: WeatherSnapshotEntity? = nil,
        originPriorityRaw: Int,
        evaluatedPeriodRaw: String? = nil,
        recommendedGarments: [ClothingItemEntity]? = nil,
        wornGarments: [ClothingItemEntity]? = nil,
        perceptionRaw: String,
        isIndoorDistortion: Bool,
        affectedZoneRaw: String? = nil,
        physicalReactionRaw: String? = nil,
        adjustedGarment: ClothingItemEntity? = nil,
        postAdjustmentStateRaw: String? = nil,
        collectionStateRaw: String = "Correcto"
    ) {
        self.id = id
        self.timestamp = timestamp
        self.weatherSnapshot = weatherSnapshot
        self.originPriorityRaw = originPriorityRaw
        self.evaluatedPeriodRaw = evaluatedPeriodRaw
        self.recommendedGarments = recommendedGarments
        self.wornGarments = wornGarments
        self.perceptionRaw = perceptionRaw
        self.isIndoorDistortion = isIndoorDistortion
        self.affectedZoneRaw = affectedZoneRaw
        self.physicalReactionRaw = physicalReactionRaw
        self.adjustedGarment = adjustedGarment
        self.postAdjustmentStateRaw = postAdjustmentStateRaw
        self.collectionStateRaw = collectionStateRaw
    }
}

import Foundation
import FoundationModels

@Generable
public enum ThermalPerception: String, Codable, CaseIterable, Sendable {
    case perfect = "Clavada / Perfecto"
    case feltCold = "Pasé frío"
    case feltHot = "Pasé calor"
}

@Generable
public enum PhysicalReaction: String, Codable, Sendable {
    case enduredAsIs = "Aguanté con lo puesto"
    case adjustedClothing = "Me añadí/quité ropa"
}

@Generable
public enum PostAdjustmentState: String, Codable, Sendable {
    case stabilized = "Estuve perfecto"
    case stillUncomfortable = "Seguí destemplado"
}

public enum DailyCollectionState: String, Codable, CaseIterable, Sendable {
    case correct = "Correcto"
    case incorrect = "Incorrecto"
    case adjusted = "Ajustado"
    case ignored = "Ignorado"
    case deleted = "Borrado"
}

public enum HistoryGarmentModification: String, Codable, Sendable {
    case kept = "Mantenida"
    case added = "Añadida"
    case removed = "Eliminada"
}

public struct HistoryGarmentItem: Identifiable, Sendable, Equatable {
    public var id: UUID { garment.id }
    public let garment: Garment
    public let modification: HistoryGarmentModification
    
    public init(garment: Garment, modification: HistoryGarmentModification) {
        self.garment = garment
        self.modification = modification
    }
}

public struct FeedbackRecord: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let weatherSnapshot: Weather
    public let originPriority: RecommendationPriority
    public let evaluatedPeriod: DayEvaluationPeriod?
    public let recommendedOutfit: Outfit?
    public let wornOutfit: Outfit
    public let perception: ThermalPerception
    public let isIndoorDistortion: Bool
    
    public let affectedZone: BodyZone?
    public let physicalReaction: PhysicalReaction?
    public let adjustedGarment: Garment?
    public let postAdjustmentState: PostAdjustmentState?
    public var collectionState: DailyCollectionState

    public var resolvesAsSuccess: Bool {
        if collectionState == .deleted || collectionState == .ignored || collectionState == .incorrect { return false }
        if isIndoorDistortion { return false }
        if perception == .perfect && collectionState == .correct { return true }
        if (collectionState == .adjusted || physicalReaction == .adjustedClothing) && postAdjustmentState == .stabilized {
            return true
        }
        return false
    }

    public var itemModifications: [HistoryGarmentItem] {
        guard let recommended = recommendedOutfit else {
            return wornOutfit.garments.map { HistoryGarmentItem(garment: $0, modification: .kept) }
        }

        let wornIDs = Set(wornOutfit.garments.map(\.id))
        let recommendedIDs = Set(recommended.garments.map(\.id))

        var items: [HistoryGarmentItem] = []

        for garment in wornOutfit.garments {
            if recommendedIDs.contains(garment.id) {
                items.append(HistoryGarmentItem(garment: garment, modification: .kept))
            } else {
                items.append(HistoryGarmentItem(garment: garment, modification: .added))
            }
        }

        for garment in recommended.garments where !wornIDs.contains(garment.id) {
            items.append(HistoryGarmentItem(garment: garment, modification: .removed))
        }

        return items
    }

    public init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        weatherSnapshot: Weather,
        originPriority: RecommendationPriority,
        evaluatedPeriod: DayEvaluationPeriod? = nil,
        recommendedOutfit: Outfit? = nil,
        wornOutfit: Outfit,
        perception: ThermalPerception,
        isIndoorDistortion: Bool = false,
        affectedZone: BodyZone? = nil,
        physicalReaction: PhysicalReaction? = nil,
        adjustedGarment: Garment? = nil,
        postAdjustmentState: PostAdjustmentState? = nil,
        collectionState: DailyCollectionState = .correct
    ) {
        self.id = id
        self.timestamp = timestamp
        self.weatherSnapshot = weatherSnapshot
        self.originPriority = originPriority
        self.evaluatedPeriod = evaluatedPeriod
        self.recommendedOutfit = recommendedOutfit
        self.wornOutfit = wornOutfit
        self.perception = perception
        self.isIndoorDistortion = isIndoorDistortion
        self.affectedZone = affectedZone
        self.physicalReaction = physicalReaction
        self.adjustedGarment = adjustedGarment
        self.postAdjustmentState = postAdjustmentState
        self.collectionState = collectionState
    }
}

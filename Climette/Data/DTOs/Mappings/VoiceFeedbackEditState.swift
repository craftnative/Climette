import Foundation
import SwiftData

/// Estructura auxiliar para transportar los datos validados hacia la UI de edición
public struct VoiceFeedbackEditState {
    public var evaluationPeriod: DayEvaluationPeriod
    public var perception: ThermalPerception
    public var isIndoorDistortion: Bool
    public var wornGarments: [ClothingItemEntity]
    public var physicalReaction: PhysicalReaction?
    public var adjustedGarment: ClothingItemEntity?
    public var postAdjustmentState: PostAdjustmentState?
}

extension VoiceFeedbackExtractionDTO {
    
    @MainActor
    public func mapToEditState(
        catalog: [ClothingItemEntity],
        currentWornGarments: [ClothingItemEntity]
    ) -> VoiceFeedbackEditState {
        
        let newWornGarments = wornGarmentNames.isEmpty ? currentWornGarments : matchGarments(names: wornGarmentNames, catalog: catalog)
        let adjustedGarments = matchGarments(names: adjustedGarmentNames, catalog: catalog)
        
        return VoiceFeedbackEditState(
            evaluationPeriod: self.evaluationPeriod,
            perception: self.perception,
            isIndoorDistortion: self.isIndoorDistortion,
            wornGarments: newWornGarments,
            physicalReaction: self.physicalReaction,
            adjustedGarment: adjustedGarments.first,
            postAdjustmentState: self.postAdjustmentState
        )
    }
    
    @MainActor
    private func matchGarments(names: [String], catalog: [ClothingItemEntity]) -> [ClothingItemEntity] {
        var matched: [ClothingItemEntity] = []
        
        for name in names {
            let query = name.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            
            // Búsqueda de coincidencia en el nombre canónico o alias personalizado
            if let found = catalog.first(where: {
                $0.canonicalName.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query) ||
                ($0.userNickname?.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(query) == true)
            }) {
                if !matched.contains(where: { $0.id == found.id }) {
                    matched.append(found)
                }
            }
        }
        
        return matched
    }
}

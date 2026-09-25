import Foundation

extension FeedbackRecordEntity {
    @MainActor public func toDomain() -> FeedbackRecord? {
        guard let weatherSnapshot = weatherSnapshot?.toDomain(),
              let baseLayer = baseLayer?.toDomain() else { return nil }
        
        let outfit = Outfit(
            id: UUID(),
            baseLayer: baseLayer,
            midLayer: midLayer?.toDomain(),
            outerLayer: outerLayer?.toDomain()
        )
        
        var evaluatedPeriod: DayEvaluationPeriod? = nil
        if let ep = evaluatedPeriodRaw {
            evaluatedPeriod = DayEvaluationPeriod(rawValue: ep)
        }
        
        var physicalReaction: PhysicalReaction? = nil
        if let pr = physicalReactionRaw {
            physicalReaction = PhysicalReaction(rawValue: pr)
        }
        
        var postAdjState: PostAdjustmentState? = nil
        if let pas = postAdjustmentStateRaw {
            postAdjState = PostAdjustmentState(rawValue: pas)
        }
        
        return FeedbackRecord(
            id: id,
            timestamp: timestamp,
            weatherSnapshot: weatherSnapshot,
            originPriority: RecommendationPriority(rawValue: originPriorityRaw) ?? .priority3ColdStart,
            evaluatedPeriod: evaluatedPeriod,
            wornOutfit: outfit,
            perception: ThermalPerception(rawValue: perceptionRaw) ?? .perfect,
            isIndoorDistortion: isIndoorDistortion,
            physicalReaction: physicalReaction,
            adjustedGarment: adjustedGarment?.toDomain(),
            isGarmentAddition: isGarmentAddition,
            postAdjustmentState: postAdjState,
            collectionState: DailyCollectionState(rawValue: collectionStateRaw) ?? .correct
        )
    }
    
    public convenience init(from domain: FeedbackRecord, weatherEntity: WeatherSnapshotEntity, baseEntity: ClothingItemEntity, midEntity: ClothingItemEntity?, outerEntity: ClothingItemEntity?, adjustedEntity: ClothingItemEntity?) {
        self.init(
            id: domain.id,
            timestamp: domain.timestamp,
            weatherSnapshot: weatherEntity,
            originPriorityRaw: domain.originPriority.rawValue,
            evaluatedPeriodRaw: domain.evaluatedPeriod?.rawValue,
            baseLayer: baseEntity,
            midLayer: midEntity,
            outerLayer: outerEntity,
            perceptionRaw: domain.perception.rawValue,
            isIndoorDistortion: domain.isIndoorDistortion,
            physicalReactionRaw: domain.physicalReaction?.rawValue,
            adjustedGarment: adjustedEntity,
            isGarmentAddition: domain.isGarmentAddition,
            postAdjustmentStateRaw: domain.postAdjustmentState?.rawValue,
            collectionStateRaw: domain.collectionState.rawValue
        )
    }
}

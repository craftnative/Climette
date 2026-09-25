import Foundation

extension FeedbackRecordEntity {
    @MainActor public func toDomain() -> FeedbackRecord? {
        guard let weatherSnapshot = weatherSnapshot?.toDomain() else { return nil }
        
        let garments = (wornGarments ?? []).map { $0.toDomain() }
        let outfit = Outfit(id: UUID(), garments: garments)
        
        var evaluatedPeriod: DayEvaluationPeriod? = nil
        if let ep = evaluatedPeriodRaw {
            evaluatedPeriod = DayEvaluationPeriod(rawValue: ep)
        }
        
        var affectedZone: BodyZone? = nil
        if let az = affectedZoneRaw {
            affectedZone = BodyZone(rawValue: az)
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
            affectedZone: affectedZone,
            physicalReaction: physicalReaction,
            adjustedGarment: adjustedGarment?.toDomain(),
            postAdjustmentState: postAdjState,
            collectionState: DailyCollectionState(rawValue: collectionStateRaw) ?? .correct
        )
    }
    
    public convenience init(
        from domain: FeedbackRecord,
        weatherEntity: WeatherSnapshotEntity,
        wornGarmentEntities: [ClothingItemEntity]?,
        adjustedEntity: ClothingItemEntity?
    ) {
        self.init(
            id: domain.id,
            timestamp: domain.timestamp,
            weatherSnapshot: weatherEntity,
            originPriorityRaw: domain.originPriority.rawValue,
            evaluatedPeriodRaw: domain.evaluatedPeriod?.rawValue,
            wornGarments: wornGarmentEntities,
            perceptionRaw: domain.perception.rawValue,
            isIndoorDistortion: domain.isIndoorDistortion,
            affectedZoneRaw: domain.affectedZone?.rawValue,
            physicalReactionRaw: domain.physicalReaction?.rawValue,
            adjustedGarment: adjustedEntity,
            postAdjustmentStateRaw: domain.postAdjustmentState?.rawValue,
            collectionStateRaw: domain.collectionState.rawValue
        )
    }
}

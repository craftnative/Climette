import Foundation
import SwiftData

@Model
public final class FeedbackRecordEntity {
    public var id: UUID = UUID()
    public var timestamp: Date = Date()
    
    @Relationship(inverse: \WeatherSnapshotEntity.feedbackRecord)
    public var weatherSnapshot: WeatherSnapshotEntity?
    
    public var originPriorityRaw: Int = 0
    public var evaluatedPeriodRaw: String?
    
    @Relationship(inverse: \ClothingItemEntity.baseLayerFeedbacks)
    public var baseLayer: ClothingItemEntity?
    
    @Relationship(inverse: \ClothingItemEntity.midLayerFeedbacks)
    public var midLayer: ClothingItemEntity?
    
    @Relationship(inverse: \ClothingItemEntity.outerLayerFeedbacks)
    public var outerLayer: ClothingItemEntity?
    
    public var perceptionRaw: String = ""
    public var isIndoorDistortion: Bool = false
    public var physicalReactionRaw: String?
    
    @Relationship(inverse: \ClothingItemEntity.adjustedGarmentFeedbacks)
    public var adjustedGarment: ClothingItemEntity?
    
    public var isGarmentAddition: Bool?
    public var postAdjustmentStateRaw: String?
    
    public var collectionStateRaw: String = ""

    public init(
        id: UUID = UUID(),
        timestamp: Date,
        weatherSnapshot: WeatherSnapshotEntity? = nil,
        originPriorityRaw: Int,
        evaluatedPeriodRaw: String? = nil,
        baseLayer: ClothingItemEntity? = nil,
        midLayer: ClothingItemEntity? = nil,
        outerLayer: ClothingItemEntity? = nil,
        perceptionRaw: String,
        isIndoorDistortion: Bool,
        physicalReactionRaw: String? = nil,
        adjustedGarment: ClothingItemEntity? = nil,
        isGarmentAddition: Bool? = nil,
        postAdjustmentStateRaw: String? = nil,
        collectionStateRaw: String = "Correcto"
    ) {
        self.id = id
        self.timestamp = timestamp
        self.weatherSnapshot = weatherSnapshot
        self.originPriorityRaw = originPriorityRaw
        self.evaluatedPeriodRaw = evaluatedPeriodRaw
        self.baseLayer = baseLayer
        self.midLayer = midLayer
        self.outerLayer = outerLayer
        self.perceptionRaw = perceptionRaw
        self.isIndoorDistortion = isIndoorDistortion
        self.physicalReactionRaw = physicalReactionRaw
        self.adjustedGarment = adjustedGarment
        self.isGarmentAddition = isGarmentAddition
        self.postAdjustmentStateRaw = postAdjustmentStateRaw
        self.collectionStateRaw = collectionStateRaw
    }
}

import Foundation
import SwiftData

@Model
public final class FeedbackRecordEntity {
    @Attribute(.unique) public var id: UUID
    public var timestamp: Date
    
    @Relationship public var weatherSnapshot: WeatherSnapshotEntity?
    public var originPriorityRaw: Int
    public var evaluatedPeriodRaw: String?
    
    @Relationship public var baseLayer: ClothingItemEntity?
    @Relationship public var midLayer: ClothingItemEntity?
    @Relationship public var outerLayer: ClothingItemEntity?
    
    public var perceptionRaw: String
    public var isIndoorDistortion: Bool
    public var physicalReactionRaw: String?
    
    @Relationship public var adjustedGarment: ClothingItemEntity?
    public var isGarmentAddition: Bool?
    public var postAdjustmentStateRaw: String?

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
        postAdjustmentStateRaw: String? = nil
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
    }
}

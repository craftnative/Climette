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

    public init(
        id: UUID = UUID(),
        timestamp: Date,
        weatherSnapshot: WeatherSnapshotEntity? = nil,
        originPriorityRaw: Int,
        evaluatedPeriodRaw: String? = nil,
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

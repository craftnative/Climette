import Foundation
import SwiftData

@Model
public final class ClothingItemEntity {
    public var id: UUID = UUID()
    public var archetypeId: String = ""
    public var canonicalName: String = ""
    public var bodyZoneRaw: String = ""
    public var layerRaw: String?
    
    public var baseThermal: Int = 1
    public var baseWind: Int = 1
    public var baseWater: Int = 1
    
    public var userNickname: String?
    public var color: String?
    public var isAvailable: Bool = true
    
    public var overrideThermal: Int?
    public var overrideWind: Int?
    public var overrideWater: Int?
    
    @Relationship(inverse: \FeedbackRecordEntity.wornGarments)
    public var outfitFeedbacks: [FeedbackRecordEntity]?
    
    @Relationship(inverse: \FeedbackRecordEntity.adjustedGarment)
    public var adjustedGarmentFeedbacks: [FeedbackRecordEntity]?

    public init(
        id: UUID = UUID(),
        archetypeId: String,
        canonicalName: String,
        bodyZoneRaw: String,
        layerRaw: String? = nil,
        baseThermal: Int = 1,
        baseWind: Int = 1,
        baseWater: Int = 1,
        userNickname: String? = nil,
        color: String? = nil,
        isAvailable: Bool = true,
        overrideThermal: Int? = nil,
        overrideWind: Int? = nil,
        overrideWater: Int? = nil
    ) {
        self.id = id
        self.archetypeId = archetypeId
        self.canonicalName = canonicalName
        self.bodyZoneRaw = bodyZoneRaw
        self.layerRaw = layerRaw
        self.baseThermal = baseThermal
        self.baseWind = baseWind
        self.baseWater = baseWater
        self.userNickname = userNickname
        self.color = color
        self.isAvailable = isAvailable
        self.overrideThermal = overrideThermal
        self.overrideWind = overrideWind
        self.overrideWater = overrideWater
    }
}

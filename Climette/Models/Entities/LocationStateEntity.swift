import Foundation
import SwiftData

@Model
public final class LocationStateEntity {
    public var id: UUID = UUID()
    public var modeRaw: String = ""
    public var latitude: Double?
    public var longitude: Double?
    public var cityName: String?
    public var lastUpdated: Date?

    public init(
        id: UUID = UUID(),
        modeRaw: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        cityName: String? = nil,
        lastUpdated: Date? = nil
    ) {
        self.id = id
        self.modeRaw = modeRaw
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.lastUpdated = lastUpdated
    }
}

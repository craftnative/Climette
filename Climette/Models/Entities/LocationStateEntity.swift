import Foundation
import SwiftData

@Model
public final class LocationStateEntity {
    public var modeRaw: String = ""
    public var latitude: Double?
    public var longitude: Double?
    public var cityName: String?
    public var lastUpdated: Date?

    public init(
        modeRaw: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        cityName: String? = nil,
        lastUpdated: Date? = nil
    ) {
        self.modeRaw = modeRaw
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.lastUpdated = lastUpdated
    }
}

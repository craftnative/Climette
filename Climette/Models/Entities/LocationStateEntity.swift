import Foundation
import SwiftData

@Model
public final class LocationStateEntity {
    public var id: UUID = UUID()
    public var modeRaw: String = ""
    
    public var manualLatitude: Double?
    public var manualLongitude: Double?
    public var manualCityName: String?
    
    public var gpsLatitude: Double?
    public var gpsLongitude: Double?
    public var gpsCityName: String?
    
    public var lastUpdated: Date?

    public init(
        id: UUID = UUID(),
        modeRaw: String,
        manualLatitude: Double? = nil,
        manualLongitude: Double? = nil,
        manualCityName: String? = nil,
        gpsLatitude: Double? = nil,
        gpsLongitude: Double? = nil,
        gpsCityName: String? = nil,
        lastUpdated: Date? = nil
    ) {
        self.id = id
        self.modeRaw = modeRaw
        self.manualLatitude = manualLatitude
        self.manualLongitude = manualLongitude
        self.manualCityName = manualCityName
        self.gpsLatitude = gpsLatitude
        self.gpsLongitude = gpsLongitude
        self.gpsCityName = gpsCityName
        self.lastUpdated = lastUpdated
    }
}

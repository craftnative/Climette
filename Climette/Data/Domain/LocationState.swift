import Foundation

public struct GeographicCoordinate: Codable, Sendable, Equatable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public enum LocationMode: String, Codable, Sendable, Equatable {
    case gps = "gps"
    case manual = "manual"
}

public struct LocationState: Codable, Sendable, Equatable {
    public var mode: LocationMode
    public var manualCoordinate: GeographicCoordinate?
    public var manualCityName: String?
    public var gpsCoordinate: GeographicCoordinate?
    public var gpsCityName: String?
    public var lastUpdated: Date?

    public var activeCityName: String? {
        mode == .manual ? manualCityName : gpsCityName
    }
    
    public var activeCoordinate: GeographicCoordinate? {
        mode == .manual ? manualCoordinate : gpsCoordinate
    }

    public init(
        mode: LocationMode = .gps,
        manualCoordinate: GeographicCoordinate? = nil,
        manualCityName: String? = nil,
        gpsCoordinate: GeographicCoordinate? = nil,
        gpsCityName: String? = nil,
        lastUpdated: Date? = nil
    ) {
        self.mode = mode
        self.manualCoordinate = manualCoordinate
        self.manualCityName = manualCityName
        self.gpsCoordinate = gpsCoordinate
        self.gpsCityName = gpsCityName
        self.lastUpdated = lastUpdated
    }
}

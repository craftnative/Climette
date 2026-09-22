import Foundation

public struct GeographicCoordinate: Codable, Sendable, Equatable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public enum LocationMode: Codable, Sendable, Equatable {
    case foregroundGPS
    case manualCity(name: String, coordinate: GeographicCoordinate)
}

public struct LocationState: Codable, Sendable, Equatable {
    public var mode: LocationMode
    public var currentCoordinate: GeographicCoordinate?
    public var lastResolvedCityName: String?
    public var lastUpdated: Date?

    public init(
        mode: LocationMode = .foregroundGPS,
        currentCoordinate: GeographicCoordinate? = nil,
        lastResolvedCityName: String? = nil,
        lastUpdated: Date? = nil
    ) {
        self.mode = mode
        self.currentCoordinate = currentCoordinate
        self.lastResolvedCityName = lastResolvedCityName
        self.lastUpdated = lastUpdated
    }
}

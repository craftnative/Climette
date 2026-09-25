import Foundation

@MainActor
extension LocationStateEntity {
    public func toDomain() -> LocationState {
        var manualCoord: GeographicCoordinate? = nil
        if let lat = manualLatitude, let lon = manualLongitude {
            manualCoord = GeographicCoordinate(latitude: lat, longitude: lon)
        }
        
        var gpsCoord: GeographicCoordinate? = nil
        if let lat = gpsLatitude, let lon = gpsLongitude {
            gpsCoord = GeographicCoordinate(latitude: lat, longitude: lon)
        }
        
        return LocationState(
            mode: LocationMode(rawValue: modeRaw) ?? .gps,
            manualCoordinate: manualCoord,
            manualCityName: manualCityName,
            gpsCoordinate: gpsCoord,
            gpsCityName: gpsCityName,
            lastUpdated: lastUpdated
        )
    }
    
    public convenience init(from domain: LocationState) {
        self.init(
            id: UUID(),
            modeRaw: domain.mode.rawValue,
            manualLatitude: domain.manualCoordinate?.latitude,
            manualLongitude: domain.manualCoordinate?.longitude,
            manualCityName: domain.manualCityName,
            gpsLatitude: domain.gpsCoordinate?.latitude,
            gpsLongitude: domain.gpsCoordinate?.longitude,
            gpsCityName: domain.gpsCityName,
            lastUpdated: domain.lastUpdated
        )
    }
}

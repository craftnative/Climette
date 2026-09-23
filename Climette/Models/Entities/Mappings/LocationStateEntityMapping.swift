import Foundation

@MainActor
extension LocationStateEntity {
    public func toDomain() -> LocationState {
        let mode: LocationMode
        if modeRaw == "manualCity", let lat = latitude, let lon = longitude, let name = cityName {
            mode = .manualCity(name: name, coordinate: GeographicCoordinate(latitude: lat, longitude: lon))
        } else {
            mode = .foregroundGPS
        }
        
        var currentCoord: GeographicCoordinate? = nil
        if let lat = latitude, let lon = longitude {
            currentCoord = GeographicCoordinate(latitude: lat, longitude: lon)
        }
        
        return LocationState(
            mode: mode,
            currentCoordinate: currentCoord,
            lastResolvedCityName: cityName,
            lastUpdated: lastUpdated
        )
    }
    
    public convenience init(from domain: LocationState) {
        var modeStr = "foregroundGPS"
        var lat = domain.currentCoordinate?.latitude
        var lon = domain.currentCoordinate?.longitude
        var city = domain.lastResolvedCityName
        
        if case .manualCity(let name, let coord) = domain.mode {
            modeStr = "manualCity"
            lat = coord.latitude
            lon = coord.longitude
            city = name
        }
        
        self.init(
            modeRaw: modeStr,
            latitude: lat,
            longitude: lon,
            cityName: city,
            lastUpdated: domain.lastUpdated
        )
    }
}

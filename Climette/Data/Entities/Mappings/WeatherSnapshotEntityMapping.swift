import Foundation

extension WeatherSnapshotEntity {
    @MainActor public func toDomain() -> Weather {
        return Weather(
            id: id,
            temperature: temperature,
            personalThermalIndex: personalThermalIndex,
            windSpeedKmh: windSpeedKmh,
            precipitation: PrecipitationState(rawValue: precipitationRaw) ?? .dry,
            skyCover: SkyCover(rawValue: skyCoverRaw) ?? .clear,
            minTemperature: minTemperature,
            maxTemperature: maxTemperature,
            recordedAt: recordedAt
        )
    }
    
    public convenience init(from domain: Weather) {
        self.init(
            id: domain.id,
            temperature: domain.temperature,
            personalThermalIndex: domain.personalThermalIndex,
            windSpeedKmh: domain.windSpeedKmh,
            precipitationRaw: domain.precipitation.rawValue,
            skyCoverRaw: domain.skyCover.rawValue,
            minTemperature: domain.minTemperature,
            maxTemperature: domain.maxTemperature,
            recordedAt: domain.recordedAt
        )
    }
}

import Foundation
import SwiftData

@Model
public final class WeatherEntity {
    public var id: UUID = UUID()
    public var temperature: Double = 0.0
    public var personalThermalIndex: Double = 0.0
    public var windSpeedKmh: Double = 0.0
    public var precipitationRaw: String = ""
    public var skyCoverRaw: String = ""
    public var minTemperature: Double = 0.0
    public var maxTemperature: Double = 0.0
    public var recordedAt: Date = Date()

    public init(
        id: UUID = UUID(),
        temperature: Double,
        personalThermalIndex: Double,
        windSpeedKmh: Double,
        precipitationRaw: String,
        skyCoverRaw: String,
        minTemperature: Double,
        maxTemperature: Double,
        recordedAt: Date
    ) {
        self.id = id
        self.temperature = temperature
        self.personalThermalIndex = personalThermalIndex
        self.windSpeedKmh = windSpeedKmh
        self.precipitationRaw = precipitationRaw
        self.skyCoverRaw = skyCoverRaw
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.recordedAt = recordedAt
    }
}

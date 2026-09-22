import Foundation
import SwiftData

@Model
public final class WeatherSnapshotEntity {
    @Attribute(.unique) public var id: UUID
    public var temperature: Double
    public var personalThermalIndex: Double
    public var windSpeedKmh: Double
    public var precipitationRaw: String
    public var skyCoverRaw: String
    public var minTemperature: Double
    public var maxTemperature: Double
    public var recordedAt: Date

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

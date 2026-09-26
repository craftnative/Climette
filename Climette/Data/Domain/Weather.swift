import Foundation
import FoundationModels

public enum PrecipitationState: String, Codable, Sendable {
    case dry = "Seco"
    case rainy = "Húmedo"
}

public enum SkyCover: String, Codable, Sendable {
    case clear = "Despejado"
    case overcast = "Cubierto"
}

@Generable
public enum DayEvaluationPeriod: String, Codable, CaseIterable, Sendable {
    case morning = "Por la mañana"
    case afternoon = "Mediodía - Tarde"
    case allDay = "Todo el día"
}

public struct Weather: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let temperature: Double
    public let personalThermalIndex: Double
    public let windSpeedKmh: Double
    public let precipitation: PrecipitationState
    public let skyCover: SkyCover
    public let minTemperature: Double
    public let maxTemperature: Double
    public let recordedAt: Date

    public var dailyThermalAmplitude: Double {
        maxTemperature - minTemperature
    }

    public var hasThermalDistortion: Bool {
        dailyThermalAmplitude >= 6.0
    }

    public init(
        id: UUID = UUID(),
        temperature: Double,
        personalThermalIndex: Double,
        windSpeedKmh: Double,
        precipitation: PrecipitationState,
        skyCover: SkyCover,
        minTemperature: Double,
        maxTemperature: Double,
        recordedAt: Date = .now
    ) {
        self.id = id
        self.temperature = temperature
        self.personalThermalIndex = personalThermalIndex
        self.windSpeedKmh = windSpeedKmh
        self.precipitation = precipitation
        self.skyCover = skyCover
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.recordedAt = recordedAt
    }

    public func matchesThermalTolerances(with other: Weather) -> Bool {
        let deltaITP = abs(self.personalThermalIndex - other.personalThermalIndex)
        let deltaWind = abs(self.windSpeedKmh - other.windSpeedKmh)
        let matchesPrecipitation = self.precipitation == other.precipitation
        let matchesSky = self.skyCover == other.skyCover

        return deltaITP <= 1.5 && deltaWind <= 10.0 && matchesPrecipitation && matchesSky
    }
}

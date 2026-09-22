import Foundation

public struct HourlyForecastDTO: Decodable, Sendable {
    public let date: Date
    public let temperature: Double
    public let apparentTemperature: Double
    public let windSpeedKmh: Double
    public let precipitationChance: Double
    public let cloudCoverFraction: Double

    public init(
        date: Date,
        temperature: Double,
        apparentTemperature: Double,
        windSpeedKmh: Double,
        precipitationChance: Double,
        cloudCoverFraction: Double
    ) {
        self.date = date
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.windSpeedKmh = windSpeedKmh
        self.precipitationChance = precipitationChance
        self.cloudCoverFraction = cloudCoverFraction
    }
}

public struct DailyForecastDTO: Decodable, Sendable {
    public let date: Date
    public let minTemperature: Double
    public let maxTemperature: Double

    public init(
        date: Date,
        minTemperature: Double,
        maxTemperature: Double
    ) {
        self.date = date
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
    }
}

public struct WeatherResponseDTO: Decodable, Sendable {
    public let latitude: Double
    public let longitude: Double
    public let fetchedAt: Date
    public let currentTemperature: Double
    public let currentApparentTemperature: Double
    public let currentWindSpeedKmh: Double
    public let hourlyForecast: [HourlyForecastDTO]
    public let dailyForecast: DailyForecastDTO

    public init(
        latitude: Double,
        longitude: Double,
        fetchedAt: Date = .now,
        currentTemperature: Double,
        currentApparentTemperature: Double,
        currentWindSpeedKmh: Double,
        hourlyForecast: [HourlyForecastDTO],
        dailyForecast: DailyForecastDTO
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.fetchedAt = fetchedAt
        self.currentTemperature = currentTemperature
        self.currentApparentTemperature = currentApparentTemperature
        self.currentWindSpeedKmh = currentWindSpeedKmh
        self.hourlyForecast = hourlyForecast
        self.dailyForecast = dailyForecast
    }
}

import Foundation
import CoreLocation
import WeatherKit

@Observable
@MainActor
final class WeatherMainViewModel {
    var domainWeather: Weather?
    var currentDemand: ClimateDemand?
    var resolvedOutfit: Outfit?
    var recommendationNotice: String?

    var hourlyForecast: [HourlyForecastDTO] = []
    var attribution: WeatherAttribution?
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let thermalEngine = ThermalEngine()

    func fetchWeather(
        for location: CLLocation,
        sensitivity: ThermalSensitivity,
        history: [FeedbackRecord],
        wardrobe: [Garment],
        preference: ClothingPreference
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let (current, hourly, daily) = try await WeatherService.shared.weather(
                for: location,
                including: .current, .hourly, .daily
            )
            self.attribution = try await WeatherService.shared.attribution

            let now = Date.now
            let calendar = Calendar.current

            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
                  let endOfTomorrow = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: tomorrow) else {
                isLoading = false
                return
            }

            let filteredHourly = hourly.filter { forecast in
                forecast.date >= now && forecast.date <= endOfTomorrow
            }

            self.hourlyForecast = filteredHourly.map {
                HourlyForecastDTO(
                    date: $0.date,
                    temperature: $0.temperature.value,
                    apparentTemperature: $0.apparentTemperature.value,
                    windSpeedKmh: $0.wind.speed.converted(to: .kilometersPerHour).value,
                    precipitationChance: $0.precipitationChance,
                    cloudCoverFraction: $0.cloudCover
                )
            }

            guard let todayDaily = daily.first(where: { calendar.isDate($0.date, inSameDayAs: now) }) else {
                isLoading = false
                return
            }

            let dailyDTO = DailyForecastDTO(
                date: todayDaily.date,
                minTemperature: todayDaily.lowTemperature.value,
                maxTemperature: todayDaily.highTemperature.value
            )

            let responseDTO = WeatherResponseDTO(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                fetchedAt: now,
                currentTemperature: current.temperature.value,
                currentApparentTemperature: current.apparentTemperature.value,
                currentWindSpeedKmh: current.wind.speed.converted(to: .kilometersPerHour).value,
                hourlyForecast: self.hourlyForecast,
                dailyForecast: dailyDTO
            )

            let weather = responseDTO.toDomain(sensitivity: sensitivity)
            self.domainWeather = weather

            let demand = thermalEngine.normalizeDemand(from: weather)
            self.currentDemand = demand

            let result = thermalEngine.resolveWithHistory(
                currentDemand: demand,
                history: history,
                wardrobe: wardrobe,
                preference: preference
            )

            switch result {
            case .validated(let outfit, let message):
                self.resolvedOutfit = outfit
                self.recommendationNotice = message

            case .warning(let outfit, let notice):
                self.resolvedOutfit = outfit
                self.recommendationNotice = notice

            case .discovery(let outfit):
                self.resolvedOutfit = outfit
                self.recommendationNotice = nil
            }

        } catch {
            self.errorMessage = "No se pudieron obtener las condiciones actuales."
            print("⚠️ WeatherKit Error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}

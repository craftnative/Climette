import AppIntents
import SwiftData
import SwiftUI
import WeatherKit
import CoreLocation

public struct GetClothingRecommendationIntent: AppIntent {
    // FIX: Convertidas a propiedades computadas para cumplir con la concurrencia estricta de Swift 6
    public static var title: LocalizedStringResource { "Consultar Recomendación" }
    public static var description: IntentDescription { IntentDescription("Obtiene la recomendación de ropa para una fecha y momento del día.") }
    
    @Parameter(title: "Día", default: .today)
    public var targetDay: TargetDayAppEnum
    
    @Parameter(title: "Momento del Día", default: .allDay)
    public var period: DayEvaluationPeriod

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let container = try ModelContainer(for: Schema([UserProfileEntity.self, LocationStateEntity.self, FeedbackRecordEntity.self, ClothingItemEntity.self, WeatherSnapshotEntity.self, WeatherEntity.self]))
        let context = container.mainContext
        
        let targetDate = targetDay.targetDate()
        let calendar = Calendar.current
        
        // 1. Caso: Fecha pasada (Historial)
        if targetDay == .yesterday || targetDate < calendar.startOfDay(for: .now) {
            let descriptor = FetchDescriptor<FeedbackRecordEntity>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
            let history = (try? context.fetch(descriptor)) ?? []
            
            guard let record = history.first(where: { calendar.isDate($0.timestamp, inSameDayAs: targetDate) }),
                  let domainRecord = record.toDomain() else {
                return .result(dialog: "No encontré un registro guardado para ese día.")
            }
            
            let view = RecommendationSnippetView(
                outfit: domainRecord.wornOutfit,
                headline: "Esto fue lo que registraste el \(targetDay.rawValue.lowercased()).",
                notice: domainRecord.perception != .perfect ? "Ese día tu sensación fue: \(domainRecord.perception.rawValue)" : nil
            )
            return .result(dialog: "Aquí tienes lo que registraste.", view: view)
        }
        
        // 2. Caso: Hoy o Mañana (Previsión)
        let locationDescriptor = FetchDescriptor<LocationStateEntity>()
        guard let locationState = try? context.fetch(locationDescriptor).first,
              let lat = locationState.modeRaw == LocationMode.gps.rawValue ? locationState.gpsLatitude : locationState.manualLatitude,
              let lon = locationState.modeRaw == LocationMode.gps.rawValue ? locationState.gpsLongitude : locationState.manualLongitude else {
            return .result(dialog: "No hay una ubicación configurada para evaluar el clima.")
        }
        
        let location = CLLocation(latitude: lat, longitude: lon)
        let (current, hourly, daily) = try await WeatherService.shared.weather(for: location, including: .current, .hourly, .daily)
        
        let filteredHourly = hourly.filter { forecast in
            calendar.isDate(forecast.date, inSameDayAs: targetDate) && isWithinPeriod(forecast.date, period: period)
        }
        
        guard let dailyForecast = daily.first(where: { calendar.isDate($0.date, inSameDayAs: targetDate) }),
              !filteredHourly.isEmpty else {
            return .result(dialog: "No dispongo de datos meteorológicos para \(targetDay.rawValue.lowercased()) en esa franja horaria.")
        }
        
        let sensitivity = ThermalSensitivity(rawValue: (try? context.fetch(FetchDescriptor<UserProfileEntity>()))?.first?.sensitivityRaw ?? "") ?? .normal
        let preference = ClothingPreference(rawValue: (try? context.fetch(FetchDescriptor<UserProfileEntity>()))?.first?.clothingPreferenceRaw ?? "") ?? .both
        let history = (try? context.fetch(FetchDescriptor<FeedbackRecordEntity>()))?.compactMap { $0.toDomain() } ?? []
        let wardrobe = (try? context.fetch(FetchDescriptor<ClothingItemEntity>()))?.map { $0.toDomain() } ?? DefaultWardrobeCatalogData.defaultWardrobeGarments()
        
        let avgApparent = filteredHourly.map(\.apparentTemperature.value).reduce(0, +) / Double(filteredHourly.count)
        let avgWind = filteredHourly.map(\.wind.speed.value).reduce(0, +) / Double(filteredHourly.count)
        let maxPrecip = filteredHourly.map(\.precipitationChance).max() ?? 0
        let maxCloud = filteredHourly.map(\.cloudCover).max() ?? 0
        
        let weatherDTO = WeatherResponseDTO(
            latitude: lat,
            longitude: lon,
            currentTemperature: filteredHourly.map(\.temperature.value).max() ?? current.temperature.value,
            currentApparentTemperature: avgApparent,
            currentWindSpeedKmh: avgWind,
            hourlyForecast: [],
            dailyForecast: DailyForecastDTO(
                date: targetDate,
                minTemperature: dailyForecast.lowTemperature.value,
                maxTemperature: dailyForecast.highTemperature.value
            )
        )
        
        var weatherDomain = weatherDTO.toDomain(sensitivity: sensitivity)
        weatherDomain = Weather(
            id: weatherDomain.id,
            temperature: weatherDomain.temperature,
            personalThermalIndex: weatherDomain.personalThermalIndex,
            windSpeedKmh: weatherDomain.windSpeedKmh,
            precipitation: maxPrecip >= 0.30 ? .rainy : .dry,
            skyCover: maxCloud >= 0.50 ? .overcast : .clear,
            minTemperature: weatherDomain.minTemperature,
            maxTemperature: weatherDomain.maxTemperature,
            recordedAt: weatherDomain.recordedAt
        )
        
        let engine = ThermalEngine()
        let demand = engine.normalizeDemand(from: weatherDomain, period: period)
        let result = engine.resolveWithHistory(currentDemand: demand, history: history, wardrobe: wardrobe, preference: preference)
        
        let (outfit, notice): (Outfit, String?)
        switch result {
        case .validated(let o, let m): outfit = o; notice = m
        case .warning(let o, let n): outfit = o; notice = n
        case .discovery(let o): outfit = o; notice = nil
        }
        
        let dialogText = "Para \(targetDay.rawValue.lowercased()) \(period.rawValue.lowercased()), te recomiendo un atuendo con \(outfit.garments.count) prendas."
        let view = RecommendationSnippetView(outfit: outfit, headline: "Recomendación para \(targetDay.rawValue)", notice: notice)
        
        return .result(dialog: IntentDialog(stringLiteral: dialogText), view: view)
    }
    
    private func isWithinPeriod(_ date: Date, period: DayEvaluationPeriod) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        switch period {
        case .morning: return hour >= 6 && hour < 14
        case .afternoon: return hour >= 14 && hour < 21
        case .allDay: return true
        }
    }
}

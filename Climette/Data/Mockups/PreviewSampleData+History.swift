#if DEBUG
import Foundation
import SwiftData

@MainActor
extension PreviewSampleData {
    public static func seedHistoryData(into context: ModelContext) {
        let calendar = Calendar.current
        let now = Date.now

        // Recuperar registros históricos existentes indexados por el inicio del día
        let feedbackDescriptor = FetchDescriptor<FeedbackRecordEntity>()
        let existingFeedbacks = (try? context.fetch(feedbackDescriptor)) ?? []
        let existingDays = Set(existingFeedbacks.map { calendar.startOfDay(for: $0.timestamp) })

        let garmentDescriptor = FetchDescriptor<ClothingItemEntity>()
        let catalog = (try? context.fetch(garmentDescriptor)) ?? []
        
        let tShirt = catalog.first(where: { $0.archetypeId == "arch_top_base_cotton_tee" })
        let tankTop = catalog.first(where: { $0.archetypeId == "arch_top_base_tank" }) ?? tShirt
        let jeans = catalog.first(where: { $0.archetypeId == "arch_bot_jeans_standard" })
        let shorts = catalog.first(where: { $0.archetypeId == "arch_bot_running_shorts" }) ?? jeans
        let jacket = catalog.first(where: { $0.archetypeId == "arch_top_outer_rain_jacket" })
        let sweater = catalog.first(where: { $0.archetypeId == "arch_top_mid_fine_knit" })
        
        var insertedCount = 0

        for daysAgo in 0..<90 {
            guard let targetDate = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }
            let dayStart = calendar.startOfDay(for: targetDate)
            
            // Omitir días que ya tengan histórico registrado
            if existingDays.contains(dayStart) {
                continue
            }
            
            // Perfil climático para Madrid (Julio - Septiembre)
            let baseTemp = 20.0 + (Double(min(daysAgo, 75)) * 0.16)
            let tempVariance = Double((daysAgo * 11) % 7) - 3.0
            let temperature = (baseTemp + tempVariance).rounded()
            
            let minTemp = temperature - 7.0
            let maxTemp = temperature + 8.0
            let windSpeed = Double(5 + ((daysAgo * 17) % 15))
            
            let isRain = daysAgo < 30 ? (daysAgo % 9 == 0) : (daysAgo % 40 == 0)
            let isOvercast = isRain || (daysAgo % 12 == 0)
            
            let collectionState: DailyCollectionState = {
                if daysAgo == 1 { return .adjusted }
                switch daysAgo % 7 {
                case 0, 1, 2, 3, 4: return .correct
                case 5:             return .adjusted
                default:            return .ignored
                }
            }()
            
            let perception: ThermalPerception = switch collectionState {
            case .correct:  .perfect
            case .adjusted: (daysAgo % 2 == 0) ? .feltCold : .feltHot
            default:        .perfect
            }
            
            let weatherSnapshot = WeatherSnapshotEntity(
                id: UUID(),
                temperature: temperature,
                personalThermalIndex: temperature + (isRain ? -1.0 : 1.5),
                windSpeedKmh: windSpeed,
                precipitationRaw: isRain ? PrecipitationState.rainy.rawValue : PrecipitationState.dry.rawValue,
                skyCoverRaw: isOvercast ? SkyCover.overcast.rawValue : SkyCover.clear.rawValue,
                minTemperature: minTemp,
                maxTemperature: maxTemp,
                recordedAt: targetDate
            )
            context.insert(weatherSnapshot)
            
            var worn: [ClothingItemEntity] = []
            
            if isRain {
                worn = [tShirt, temperature < 22.0 ? sweater : nil, jacket, jeans].compactMap { $0 }
            } else if temperature >= 29.0 {
                worn = [tankTop, shorts].compactMap { $0 }
            } else if temperature >= 24.0 {
                worn = [tShirt, shorts].compactMap { $0 }
            } else if temperature >= 18.0 {
                worn = [tShirt, jeans].compactMap { $0 }
            } else {
                worn = [tShirt, sweater, jeans].compactMap { $0 }
            }
            
            let feedback = FeedbackRecordEntity(
                id: UUID(),
                timestamp: targetDate,
                weatherSnapshot: weatherSnapshot,
                originPriorityRaw: RecommendationPriority.priority1ValidatedSuccess.rawValue,
                evaluatedPeriodRaw: DayEvaluationPeriod.allDay.rawValue,
                wornGarments: worn.isEmpty ? nil : worn,
                perceptionRaw: perception.rawValue,
                isIndoorDistortion: (daysAgo % 15 == 0),
                collectionStateRaw: collectionState.rawValue
            )
            context.insert(feedback)
            insertedCount += 1
        }

        if insertedCount > 0 {
            try? context.save()
        }
    }
}
#endif

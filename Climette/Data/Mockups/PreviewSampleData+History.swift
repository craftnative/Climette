#if DEBUG
import Foundation
import SwiftData

@MainActor
extension PreviewSampleData {
    public static func seedHistoryData(into context: ModelContext) {
        let calendar = Calendar.current
        let now = Date.now

        let garmentDescriptor = FetchDescriptor<ClothingItemEntity>()
        let catalog = (try? context.fetch(garmentDescriptor)) ?? []
        
        let tShirt = catalog.first(where: { $0.archetypeId == "arch_top_base_cotton_tee" })
        let jeans = catalog.first(where: { $0.archetypeId == "arch_bot_jeans_standard" })
        let jacket = catalog.first(where: { $0.archetypeId == "arch_top_outer_rain_jacket" })
        let sweater = catalog.first(where: { $0.archetypeId == "arch_top_mid_fine_knit" })
        
        for daysAgo in 0..<90 {
            guard let targetDate = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }
            
            let baseTemp = 24.0 - (Double(daysAgo) * 0.15)
            let tempVariance = Double((daysAgo * 7) % 9) - 4.0
            let temperature = (baseTemp + tempVariance).rounded()
            let windSpeed = Double(8 + ((daysAgo * 13) % 28))
            let isRain = (daysAgo % 5 == 0)
            let isSnow = (temperature <= 0.0)
            let isOvercast = isRain || (daysAgo % 3 == 0)
            
            let collectionState: DailyCollectionState = {
                if daysAgo == 1 { return .adjusted }
                switch daysAgo % 7 {
                case 0, 1, 2, 3: return .correct
                case 4:          return .adjusted
                case 5:          return .ignored
                default:         return .deleted
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
                personalThermalIndex: temperature - 1.0,
                windSpeedKmh: windSpeed,
                precipitationRaw: (isRain || isSnow) ? PrecipitationState.rainy.rawValue : PrecipitationState.dry.rawValue,
                skyCoverRaw: isOvercast ? SkyCover.overcast.rawValue : SkyCover.clear.rawValue,
                minTemperature: temperature - 4.0,
                maxTemperature: temperature + 4.0,
                recordedAt: targetDate
            )
            context.insert(weatherSnapshot)
            
            var worn: [ClothingItemEntity] = []
            if daysAgo == 1 {
                worn = [tShirt, jacket, jeans].compactMap { $0 }
            } else if isRain || isSnow {
                worn = [tShirt, sweater, jacket, jeans].compactMap { $0 }
            } else if temperature < 15.0 {
                worn = [tShirt, sweater, jeans].compactMap { $0 }
            } else {
                worn = [tShirt, jeans].compactMap { $0 }
            }
            
            let feedback = FeedbackRecordEntity(
                id: UUID(),
                timestamp: targetDate,
                weatherSnapshot: weatherSnapshot,
                originPriorityRaw: 1,
                evaluatedPeriodRaw: DayEvaluationPeriod.allDay.rawValue,
                wornGarments: worn.isEmpty ? nil : worn,
                perceptionRaw: perception.rawValue,
                isIndoorDistortion: (daysAgo % 11 == 0),
                collectionStateRaw: collectionState.rawValue
            )
            context.insert(feedback)
        }
    }
}
#endif

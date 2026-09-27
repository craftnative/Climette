#if DEBUG
import Foundation
import SwiftData

@MainActor
extension PreviewSampleData {
    public static func seedHistoryData(into context: ModelContext) {
        let calendar = Calendar.current
        let now = Date.now

        let feedbackDescriptor = FetchDescriptor<FeedbackRecordEntity>()
        let existingFeedbacks = (try? context.fetch(feedbackDescriptor)) ?? []
        let existingDays = Set(existingFeedbacks.map { calendar.startOfDay(for: $0.timestamp) })

        let garmentDescriptor = FetchDescriptor<ClothingItemEntity>()
        let catalog = (try? context.fetch(garmentDescriptor)) ?? []
        
        guard let tShirt = catalog.first(where: { $0.archetypeId == "arch_top_base_cotton_tee" }),
              let jeans = catalog.first(where: { $0.archetypeId == "arch_bot_jeans_standard" }) else {
            return
        }
        
        let tankTop = catalog.first(where: { $0.archetypeId == "arch_top_base_tank" }) ?? tShirt
        let shorts = catalog.first(where: { $0.archetypeId == "arch_bot_running_shorts" }) ?? jeans
        let jacket = catalog.first(where: { $0.archetypeId == "arch_top_outer_rain_jacket" })
        let sweater = catalog.first(where: { $0.archetypeId == "arch_top_mid_fine_knit" })
        
        var insertedCount = 0

        for daysAgo in 0..<30 {
            guard let targetDate = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }
            let dayStart = calendar.startOfDay(for: targetDate)
            
            if existingDays.contains(dayStart) {
                continue
            }
            
            let dayIndex = Double(daysAgo)
            let synopticWave = sin(dayIndex * 0.45) * 3.5 + cos(dayIndex * 0.18) * 1.5
            let temperature = (21.5 + synopticWave).rounded()
            
            let minTemp = temperature - 4.5
            let maxTemp = temperature + 5.0
            let windSpeed = 8.0 + (abs(sin(dayIndex * 0.35)) * 12.0).rounded()
            
            let isRain = synopticWave < -2.0 && (daysAgo % 2 == 0)
            let isOvercast = isRain || (synopticWave < 0.0 && daysAgo % 3 == 0)
            
            let collectionState: DailyCollectionState = {
                switch daysAgo {
                case 4, 11, 18, 25:
                    return .adjusted
                case 8, 22:
                    return .incorrect
                default:
                    return .correct
                }
            }()
            
            let perception: ThermalPerception = {
                switch collectionState {
                case .correct:
                    return .perfect
                case .adjusted, .incorrect:
                    return synopticWave < 0.0 ? .feltCold : .feltHot
                default:
                    return .perfect
                }
            }()
            
            let weatherSnapshot = WeatherSnapshotEntity(
                id: UUID(),
                temperature: temperature,
                personalThermalIndex: temperature + (isRain ? -1.5 : (windSpeed > 15 ? -1.0 : 1.0)),
                windSpeedKmh: windSpeed,
                precipitationRaw: isRain ? PrecipitationState.rainy.rawValue : PrecipitationState.dry.rawValue,
                skyCoverRaw: isOvercast ? SkyCover.overcast.rawValue : SkyCover.clear.rawValue,
                minTemperature: minTemp,
                maxTemperature: maxTemp,
                recordedAt: targetDate
            )
            context.insert(weatherSnapshot)
            
            var recommendedGarments: [ClothingItemEntity] = []
            var wornGarments: [ClothingItemEntity] = []
            var adjustedGarment: ClothingItemEntity? = nil
            var physicalReaction: String? = nil
            var postAdjustmentState: String? = nil
            
            if collectionState == .adjusted {
                physicalReaction = PhysicalReaction.adjustedClothing.rawValue
                postAdjustmentState = PostAdjustmentState.stabilized.rawValue
                
                if perception == .feltHot {
                    // Recomendación original abrigada: Camiseta + Jersey + Vaqueros
                    let safeSweater = sweater ?? tShirt
                    recommendedGarments = [tShirt, safeSweater, jeans]
                    
                    // El usuario pasó calor y se retiró el jersey (jersey = retirada, camiseta y vaqueros = base/kept)
                    wornGarments = [tShirt, jeans]
                    adjustedGarment = safeSweater
                } else {
                    // Recomendación original ligera: Camiseta + Vaqueros
                    recommendedGarments = [tShirt, jeans]
                    
                    // El usuario pasó frío y se añadió una capa exterior o jersey
                    let extraLayer = (windSpeed > 14.0 ? jacket : sweater) ?? sweater ?? tShirt
                    wornGarments = [tShirt, extraLayer, jeans]
                    adjustedGarment = extraLayer
                }
            } else {
                // Estados Correcto o Incorrecto sin ajuste
                if isRain {
                    recommendedGarments = [tShirt, sweater, jacket, jeans].compactMap { $0 }
                } else if temperature >= 25.0 {
                    recommendedGarments = [tankTop, shorts]
                } else if temperature >= 21.0 {
                    recommendedGarments = [tShirt, shorts]
                } else if temperature >= 18.0 {
                    recommendedGarments = [tShirt, jeans]
                } else {
                    recommendedGarments = [tShirt, sweater, jeans].compactMap { $0 }
                }
                
                wornGarments = recommendedGarments
                if collectionState == .incorrect {
                    physicalReaction = PhysicalReaction.enduredAsIs.rawValue
                }
            }
            
            let feedback = FeedbackRecordEntity(
                id: UUID(),
                timestamp: targetDate,
                weatherSnapshot: weatherSnapshot,
                originPriorityRaw: RecommendationPriority.priority1ValidatedSuccess.rawValue,
                evaluatedPeriodRaw: DayEvaluationPeriod.allDay.rawValue,
                recommendedGarments: recommendedGarments,
                wornGarments: wornGarments,
                perceptionRaw: perception.rawValue,
                isIndoorDistortion: (daysAgo == 15),
                physicalReactionRaw: physicalReaction,
                adjustedGarment: adjustedGarment,
                postAdjustmentStateRaw: postAdjustmentState,
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

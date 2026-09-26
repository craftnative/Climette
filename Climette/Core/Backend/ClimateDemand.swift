import Foundation

public struct ClimateDemand: Sendable, Equatable {
    public let thermal: Int
    public let wind: Int
    public let humidity: Int
    public let requiresRainProtection: Bool
    
    public init(thermal: Int, wind: Int, humidity: Int, requiresRainProtection: Bool) {
        self.thermal = max(1, min(10, thermal))
        self.wind = max(1, min(10, wind))
        self.humidity = max(1, min(10, humidity))
        self.requiresRainProtection = requiresRainProtection
    }
}

public enum HierarchyResult: Sendable {
    case validated(outfit: Outfit, message: String)
    case warning(outfit: Outfit, notice: String)
    case discovery(outfit: Outfit)
}

public struct ThermalEngine: Sendable {
    
    public init() {}
    
    public func resolveWithHistory(
        currentDemand: ClimateDemand,
        history: [FeedbackRecord],
        wardrobe: [Garment]
    ) -> HierarchyResult {
        let validHistory = history.filter { !$0.isIndoorDistortion && $0.collectionState != .deleted && $0.collectionState != .ignored }
        
        var bestMatch: (record: FeedbackRecord, distance: Int)?
        var closestWarning: (record: FeedbackRecord, distance: Int)?
        
        for record in validHistory {
            let historicalDemand = normalizeDemand(from: record.weatherSnapshot)
            
            let diffT = abs(currentDemand.thermal - historicalDemand.thermal)
            let diffV = abs(currentDemand.wind - historicalDemand.wind)
            let diffH = abs(currentDemand.humidity - historicalDemand.humidity)
            
            let totalDistance = (diffT * 2) + diffV + diffH
            
            if totalDistance <= 1 && record.perception == .perfect {
                if let current = bestMatch {
                    if totalDistance < current.distance {
                        bestMatch = (record, totalDistance)
                    }
                } else {
                    bestMatch = (record, totalDistance)
                }
            }
            
            if diffT <= 1 && (record.perception == .feltCold || record.perception == .feltHot) {
                if let current = closestWarning {
                    if totalDistance < current.distance {
                        closestWarning = (record, totalDistance)
                    }
                } else {
                    closestWarning = (record, totalDistance)
                }
            }
        }
        
        // 1. Coincidencia validada perfecta
        if let match = bestMatch {
            return .validated(
                outfit: match.record.wornOutfit,
                message: "Condiciones idénticas a un día validado previamente. Ropa confirmada."
            )
        }
        
        // 2. Corrección por retroalimentación previa
        if let failure = closestWarning {
            switch failure.record.perception {
            case .feltCold:
                let adjustedDemand = ClimateDemand(
                    thermal: min(currentDemand.thermal + 1, 10),
                    wind: currentDemand.wind,
                    humidity: currentDemand.humidity,
                    requiresRainProtection: currentDemand.requiresRainProtection
                )
                let outfit = generateRecommendedOutfit(demand: adjustedDemand, wardrobe: wardrobe)
                return .warning(
                    outfit: outfit,
                    notice: "Aviso: La última vez pasaste frío con este clima. Se añade mayor aislamiento."
                )
                
            case .feltHot:
                let adjustedDemand = ClimateDemand(
                    thermal: max(currentDemand.thermal - 1, 1),
                    wind: currentDemand.wind,
                    humidity: currentDemand.humidity,
                    requiresRainProtection: currentDemand.requiresRainProtection
                )
                let outfit = generateRecommendedOutfit(demand: adjustedDemand, wardrobe: wardrobe)
                return .warning(
                    outfit: outfit,
                    notice: "Aviso: La última vez pasaste calor con este clima. Se reduce la carga térmica."
                )
                
            default:
                break
            }
        }
        
        // 3. Descubrimiento / Cold Start
        let recommendedOutfit = generateRecommendedOutfit(demand: currentDemand, wardrobe: wardrobe)
        return .discovery(outfit: recommendedOutfit)
    }
    
    /// Ensamblaje canónico de capas y zonas según demanda climática y armario disponible
    public func generateRecommendedOutfit(demand: ClimateDemand, wardrobe: [Garment]) -> Outfit {
        let availableGarments = wardrobe.filter { $0.isAvailable }
        var selectedGarments: [Garment] = []

        // MARK: - 1. Torso Superior
        let upperGarments = availableGarments.filter { $0.archetype.bodyZone == .upperTorso }
        
        // Capa Base: obligatoria en todo escenario
        let baseLayers = upperGarments.filter { $0.archetype.supportedLayer == .base }
        if let base = selectClosestGarment(from: baseLayers, targetThermal: min(demand.thermal, 4)) {
            selectedGarments.append(base)
        }

        // Capa Intermedia: a partir de 14 °C hacia abajo (demand.thermal >= 5)
        if demand.thermal >= 5 {
            let midLayers = upperGarments.filter { $0.archetype.supportedLayer == .mid }
            if let mid = selectClosestGarment(from: midLayers, targetThermal: demand.thermal - 2) {
                selectedGarments.append(mid)
            }
        }

        // Capa Exterior: frío severo (thermal >= 6), viento alto (>= 6) o lluvia
        if demand.thermal >= 6 || demand.wind >= 6 || demand.requiresRainProtection {
            let outerLayers = upperGarments.filter { $0.archetype.supportedLayer == .outer }
            let filteredOuter: [Garment]
            
            if demand.requiresRainProtection {
                let rainOuter = outerLayers.filter { $0.effectiveProtection.water >= 7 }
                filteredOuter = rainOuter.isEmpty ? outerLayers : rainOuter
            } else {
                filteredOuter = outerLayers
            }

            if let outer = selectClosestGarment(from: filteredOuter, targetThermal: max(2, demand.thermal - 2)) {
                selectedGarments.append(outer)
            }
        }

        // MARK: - 2. Piernas / Inferior
        let lowerGarments = availableGarments.filter { $0.archetype.bodyZone == .lowerBody }
        if let lower = selectClosestGarment(from: lowerGarments, targetThermal: demand.thermal) {
            selectedGarments.append(lower)
        }

        // MARK: - 3. Pies
        let feetGarments = availableGarments.filter { $0.archetype.bodyZone == .feet }
        let suitableFeet: [Garment]
        if demand.requiresRainProtection {
            let waterproof = feetGarments.filter { $0.effectiveProtection.water >= 6 }
            suitableFeet = waterproof.isEmpty ? feetGarments : waterproof
        } else {
            suitableFeet = feetGarments
        }
        if let feet = selectClosestGarment(from: suitableFeet, targetThermal: demand.thermal) {
            selectedGarments.append(feet)
        }

        // MARK: - 4. Cabeza / Cuello (solo frío intenso <= 6 °C o lluvia)
        if demand.thermal >= 7 || (demand.requiresRainProtection && demand.thermal >= 5) {
            let headGarments = availableGarments.filter { $0.archetype.bodyZone == .headNeck }
            if let head = selectClosestGarment(from: headGarments, targetThermal: demand.thermal) {
                selectedGarments.append(head)
            }
        }

        // MARK: - 5. Manos (solo frío severo <= 2 °C)
        if demand.thermal >= 8 {
            let handGarments = availableGarments.filter { $0.archetype.bodyZone == .hands }
            if let hands = selectClosestGarment(from: handGarments, targetThermal: demand.thermal) {
                selectedGarments.append(hands)
            }
        }

        // MARK: - 6. Paraguas si hay precipitación
        if demand.requiresRainProtection {
            if let umbrella = availableGarments.first(where: { $0.archetype.id == "arch_acc_storm_umbrella" }) {
                selectedGarments.append(umbrella)
            }
        }

        return Outfit(id: UUID(), garments: selectedGarments)
    }

    private func selectClosestGarment(from candidates: [Garment], targetThermal: Int) -> Garment? {
        candidates.min { a, b in
            abs(a.effectiveProtection.thermal - targetThermal) < abs(b.effectiveProtection.thermal - targetThermal)
        }
    }
    
    public func normalizeDemand(from weather: Weather) -> ClimateDemand {
        let itp = weather.personalThermalIndex
        
        let normalizedThermal: Int = switch itp {
        case 26...:     1   // Muy caluroso
        case 22..<26:   2   // Cálido
        case 18..<22:   3   // Templado
        case 14..<18:   4   // Fresco
        case 10..<14:   5   // Frío suave
        case 6..<10:    6   // Frío
        case 2..<6:     7   // Frío intenso
        case -2..<2:    8   // Muy frío
        case -6..<(-2): 9   // Helada
        default:        10  // Extremo / Polar
        }
        
        let normalizedWind = max(1, min(10, Int(weather.windSpeedKmh / 7.0)))
        let normalizedHumidity = weather.precipitation == .rainy ? 8 : 3
        
        return ClimateDemand(
            thermal: normalizedThermal,
            wind: normalizedWind,
            humidity: normalizedHumidity,
            requiresRainProtection: weather.precipitation == .rainy
        )
    }
}

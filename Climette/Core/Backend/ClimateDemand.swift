import Foundation

public struct ClimateDemand: Sendable, Equatable {
    public let peakThermal: Int // Demanda térmica máxima (Momento más frío)
    public let baseThermal: Int // Demanda térmica mínima (Momento más cálido)
    public let wind: Int
    public let humidity: Int
    public let requiresRainProtection: Bool
    
    public init(peakThermal: Int, baseThermal: Int, wind: Int, humidity: Int, requiresRainProtection: Bool) {
        self.peakThermal = max(1, min(10, peakThermal))
        self.baseThermal = max(1, min(10, baseThermal))
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
            wardrobe: [Garment],
            preference: ClothingPreference
        ) -> HierarchyResult {
            let validHistory = history.filter { record in
                if record.isIndoorDistortion || record.collectionState == .deleted || record.collectionState == .ignored {
                    return false
                }
                
                // Aseguramos que el atuendo histórico cumple estrictamente con la preferencia actual
                return record.wornOutfit.garments.allSatisfy { garment in
                    switch preference {
                    case .pantsOnly:
                        return garment.archetype.styleCategory != .dress && garment.archetype.styleCategory != .skirt
                    case .skirtsAndDressesOnly:
                        return garment.archetype.styleCategory != .pants
                    case .both:
                        return true
                    }
                }
            }
            
            var bestMatch: (record: FeedbackRecord, distance: Int)?
            var closestWarning: (record: FeedbackRecord, distance: Int)?
            
            for record in validHistory {
                let historicalDemand = normalizeDemand(from: record.weatherSnapshot)
                
                // Comparamos priorizando el momento de mayor rigor térmico (peakThermal)
                let diffT = abs(currentDemand.peakThermal - historicalDemand.peakThermal)
                let diffV = abs(currentDemand.wind - historicalDemand.wind)
                let diffH = abs(currentDemand.humidity - historicalDemand.humidity)
                
                let totalDistance = (diffT * 2) + diffV + diffH
                
                if totalDistance <= 1 && record.perception == .perfect {
                    if let current = bestMatch {
                        if totalDistance < current.distance { bestMatch = (record, totalDistance) }
                    } else {
                        bestMatch = (record, totalDistance)
                    }
                }
                
                if diffT <= 1 && (record.perception == .feltCold || record.perception == .feltHot) {
                    if let current = closestWarning {
                        if totalDistance < current.distance { closestWarning = (record, totalDistance) }
                    } else {
                        closestWarning = (record, totalDistance)
                    }
                }
            }
            
            if let match = bestMatch {
                return .validated(
                    outfit: match.record.wornOutfit,
                    message: "Condiciones idénticas a un día validado previamente. Ropa confirmada."
                )
            }
            
            if let failure = closestWarning {
                switch failure.record.perception {
                case .feltCold:
                    let adjustedDemand = ClimateDemand(
                        peakThermal: min(currentDemand.peakThermal + 1, 10),
                        baseThermal: currentDemand.baseThermal,
                        wind: currentDemand.wind,
                        humidity: currentDemand.humidity,
                        requiresRainProtection: currentDemand.requiresRainProtection
                    )
                    return .warning(
                        outfit: generateRecommendedOutfit(demand: adjustedDemand, wardrobe: wardrobe, preference: preference),
                        notice: "Aviso: La última vez pasaste frío con este clima. Se añade mayor aislamiento."
                    )
                    
                case .feltHot:
                    let adjustedDemand = ClimateDemand(
                        peakThermal: max(currentDemand.peakThermal - 1, 1),
                        baseThermal: max(currentDemand.baseThermal - 1, 1),
                        wind: currentDemand.wind,
                        humidity: currentDemand.humidity,
                        requiresRainProtection: currentDemand.requiresRainProtection
                    )
                    return .warning(
                        outfit: generateRecommendedOutfit(demand: adjustedDemand, wardrobe: wardrobe, preference: preference),
                        notice: "Aviso: La última vez pasaste calor con este clima. Se reduce la carga térmica."
                    )
                    
                default: break
                }
            }
            
            return .discovery(outfit: generateRecommendedOutfit(demand: currentDemand, wardrobe: wardrobe, preference: preference))
        }
    
    public func generateRecommendedOutfit(demand: ClimateDemand, wardrobe: [Garment], preference: ClothingPreference) -> Outfit {
        let availableGarments = wardrobe.filter { $0.isAvailable }
        
        // 0. Aplicar Filtro de Preferencia (Pantalon/Falda/Vestido)
        let filteredByPreference = availableGarments.filter { garment in
            switch preference {
            case .pantsOnly:
                return garment.archetype.styleCategory != .dress && garment.archetype.styleCategory != .skirt
            case .skirtsAndDressesOnly:
                return garment.archetype.styleCategory != .pants
            case .both:
                return true
            }
        }

        var selectedGarments: [Garment] = []
        var hasFullBodyDress = false

        // 1. Evaluar si usamos vestido (Full Body)
        let dresses = filteredByPreference.filter { $0.archetype.bodyZone == .fullBody }
        if !dresses.isEmpty {
            // Buscamos un vestido que cubra la temperatura base (mínima exigencia del día)
            if let dress = selectClosestGarment(from: dresses, targetThermal: demand.baseThermal) {
                selectedGarments.append(dress)
                hasFullBodyDress = true
            }
        }

        let upperGarments = filteredByPreference.filter { $0.archetype.bodyZone == .upperTorso }
        
        // 2. Capa Base Superior (Solo si no hay vestido que ya actúe como base)
        if !hasFullBodyDress {
            let baseLayers = upperGarments.filter { $0.archetype.supportedLayer == .base }
            if let base = selectClosestGarment(from: baseLayers, targetThermal: demand.baseThermal) {
                selectedGarments.append(base)
            }
        }

        // 3. Capa Intermedia (Cubre el salto térmico de pico, compatible con vestido si refresca)
        if demand.peakThermal >= 5 && demand.peakThermal > demand.baseThermal {
            let midLayers = upperGarments.filter { $0.archetype.supportedLayer == .mid }
            let targetMid = max(1, demand.peakThermal - demand.baseThermal)
            if let mid = selectClosestGarment(from: midLayers, targetThermal: targetMid) {
                selectedGarments.append(mid)
            }
        }

        // 4. Capa Exterior (Frío severo o lluvia, compatible con vestido)
        if demand.peakThermal >= 6 || demand.wind >= 6 || demand.requiresRainProtection {
            let outerLayers = upperGarments.filter { $0.archetype.supportedLayer == .outer }
            let filteredOuter: [Garment]
            
            if demand.requiresRainProtection {
                let rainOuter = outerLayers.filter { $0.effectiveProtection.water >= 7 }
                filteredOuter = rainOuter.isEmpty ? outerLayers : rainOuter
            } else {
                filteredOuter = outerLayers
            }

            let targetOuter = max(2, demand.peakThermal - demand.baseThermal - 1)
            if let outer = selectClosestGarment(from: filteredOuter, targetThermal: targetOuter) {
                selectedGarments.append(outer)
            }
        }

        // 5. Tren Inferior (Solo se pone pantalón o falda si no lleva vestido)
        if !hasFullBodyDress {
            let lowerGarments = filteredByPreference.filter { $0.archetype.bodyZone == .lowerBody }
            if let lower = selectClosestGarment(from: lowerGarments, targetThermal: demand.peakThermal) {
                selectedGarments.append(lower)
            }
        }

        // 6. Extremidades y Accesorios
        let feetGarments = filteredByPreference.filter { $0.archetype.bodyZone == .feet }
        let suitableFeet = demand.requiresRainProtection ?
            (feetGarments.filter { $0.effectiveProtection.water >= 6 }.isEmpty ? feetGarments : feetGarments.filter { $0.effectiveProtection.water >= 6 }) : feetGarments
        if let feet = selectClosestGarment(from: suitableFeet, targetThermal: demand.peakThermal) {
            selectedGarments.append(feet)
        }

        if demand.peakThermal >= 7 || (demand.requiresRainProtection && demand.peakThermal >= 5) {
            let headGarments = filteredByPreference.filter { $0.archetype.bodyZone == .headNeck }
            if let head = selectClosestGarment(from: headGarments, targetThermal: demand.peakThermal) {
                selectedGarments.append(head)
            }
        }

        if demand.peakThermal >= 8 {
            let handGarments = filteredByPreference.filter { $0.archetype.bodyZone == .hands }
            if let hands = selectClosestGarment(from: handGarments, targetThermal: demand.peakThermal) {
                selectedGarments.append(hands)
            }
        }

        if demand.requiresRainProtection, let umbrella = filteredByPreference.first(where: { $0.archetype.id == "arch_acc_storm_umbrella" }) {
            selectedGarments.append(umbrella)
        }

        return Outfit(id: UUID(), garments: selectedGarments)
    }

    private func selectClosestGarment(from candidates: [Garment], targetThermal: Int) -> Garment? {
        candidates.min { abs($0.effectiveProtection.thermal - targetThermal) < abs($1.effectiveProtection.thermal - targetThermal) }
    }
    
    private func getThermalDemand(for index: Double) -> Int {
        switch index {
        case 26...:     return 1
        case 22..<26:   return 2
        case 18..<22:   return 3
        case 14..<18:   return 4
        case 10..<14:   return 5
        case 6..<10:    return 6
        case 2..<6:     return 7
        case -2..<2:    return 8
        case -6..<(-2): return 9
        default:        return 10
        }
    }

    public func normalizeDemand(from weather: Weather) -> ClimateDemand {
        // Demanda instantánea (momento actual/frío)
        let peakDemand = getThermalDemand(for: weather.personalThermalIndex)
        // Demanda base (momento de máxima temperatura si hay gran amplitud)
        let baseDemand = weather.hasThermalDistortion ? getThermalDemand(for: weather.maxTemperature) : peakDemand
        
        return ClimateDemand(
            peakThermal: peakDemand,
            baseThermal: baseDemand,
            wind: max(1, min(10, Int(weather.windSpeedKmh / 7.0))),
            humidity: weather.precipitation == .rainy ? 8 : 3,
            requiresRainProtection: weather.precipitation == .rainy
        )
    }
}

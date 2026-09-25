import Foundation

// MARK: - Modelos de Demanda y Resolución

public struct DemandaClimatica: Sendable, Equatable {
    public let termica: Int
    public let viento: Int
    public let humedad: Int
    public let requiereProteccionLluvia: Bool
    
    public init(termica: Int, viento: Int, humedad: Int, requiereProteccionLluvia: Bool) {
        self.termica = termica
        self.viento = viento
        self.humedad = humedad
        self.requiereProteccionLluvia = requiereProteccionLluvia
    }
}

public enum ResultadoJerarquia: Sendable {
    /// Prioridad 1: Clima idéntico con éxito previo validado.
    case validada(prendas: [Garment], mensaje: String)
    /// Prioridad 2: Clima similar donde hubo incomodidad; incluye advertencia.
    case advertencia(prendasSugeridas: [[Garment]], aviso: String)
    /// Prioridad 3: Clima nuevo; cálculo estándar directo del armario.
    case descubrimiento(demanda: DemandaClimatica)
}

// MARK: - Motor Térmico (Swift 6)

public struct MotorTermico: Sendable {
    
    public init() {}
    
    /// Evalúa el historial previo frente a la demanda meteorológica del día utilizando el cálculo de distancias.
    public func resolverConHistorial(
        demandaActual: DemandaClimatica,
        historial: [FeedbackRecord],
        armario: [Garment]
    ) -> ResultadoJerarquia {
        
        // 1. Filtrar registros descartando distorsiones ambientales (AC/Calefacción)
        let historialValido = historial.filter { !$0.isIndoorDistortion }
        
        var mejorCoincidencia: (registro: FeedbackRecord, distancia: Int)?
        var advertenciaMasCercana: (registro: FeedbackRecord, distancia: Int)?
        
        // 2. Calcular distancias matemáticas
        for registro in historialValido {
            let demandaHist = normalizarDemanda(desde: registro.weatherSnapshot)
            
            let diffT = abs(demandaActual.termica - demandaHist.termica)
            let diffV = abs(demandaActual.viento - demandaHist.viento)
            let diffH = abs(demandaActual.humedad - demandaHist.humedad)
            
            let distanciaTotal = (diffT * 2) + diffV + diffH
            
            // Hit Prioridad 1: Día Idéntico (Distancia <= 1) y confort perfecto
            if distanciaTotal <= 1 && registro.perception == .perfect {
                if let actual = mejorCoincidencia {
                    if distanciaTotal < actual.distancia {
                        mejorCoincidencia = (registro, distanciaTotal)
                    }
                } else {
                    mejorCoincidencia = (registro, distanciaTotal)
                }
            }
            
            // Hit Prioridad 2: Día Similar (Margen térmico <= 1) con fallo previo
            if diffT <= 1 && (registro.perception == .feltCold || registro.perception == .feltHot) {
                if let actual = advertenciaMasCercana {
                    if distanciaTotal < actual.distancia {
                        advertenciaMasCercana = (registro, distanciaTotal)
                    }
                } else {
                    advertenciaMasCercana = (registro, distanciaTotal)
                }
            }
        }
        
        // 3. Resolución de la Jerarquía
        if let coincidencia = mejorCoincidencia {
            return .validada(
                prendas: coincidencia.registro.wornOutfit.garments,
                mensaje: "Condiciones idénticas a un día validado previamente. Ropa confirmada."
            )
        }
        
        if let fallo = advertenciaMasCercana {
            switch fallo.registro.perception {
            case .feltCold:
                let demandaAjustada = DemandaClimatica(
                    termica: min(demandaActual.termica + 1, 10),
                    viento: demandaActual.viento,
                    humedad: demandaActual.humedad,
                    requiereProteccionLluvia: demandaActual.requiereProteccionLluvia
                )
                let prendas = evaluarCompatibilidad(demanda: demandaAjustada, armario: armario)
                return .advertencia(
                    prendasSugeridas: prendas,
                    aviso: "Aviso: La última vez pasaste frío con este clima. Se añade mayor aislamiento."
                )
                
            case .feltHot:
                let demandaAjustada = DemandaClimatica(
                    termica: max(demandaActual.termica - 1, 1),
                    viento: demandaActual.viento,
                    humedad: demandaActual.humedad,
                    requiereProteccionLluvia: demandaActual.requiereProteccionLluvia
                )
                let prendas = evaluarCompatibilidad(demanda: demandaAjustada, armario: armario)
                return .advertencia(
                    prendasSugeridas: prendas,
                    aviso: "Aviso: La última vez pasaste calor con este clima. Se reduce la carga térmica."
                )
                
            default:
                break
            }
        }
        
        // 4. Clima inédito (Prioridad 3: Descubrimiento)
        return .descubrimiento(demanda: demandaActual)
    }
    
    // MARK: - Helpers Privados
    
    private func evaluarCompatibilidad(demanda: DemandaClimatica, armario: [Garment]) -> [[Garment]] {
        // Estructura preparada para el nuevo sistema con subprendas.
        // Retorna un array multidimensional agrupando por capas/zonas. Pendiente de inyección de datos.
        return []
    }
    
    private func normalizarDemanda(desde clima: Weather) -> DemandaClimatica {
        // Adaptador para convertir el snapshot meteorológico existente al vector de cálculo (escala 1-10)
        let termicaNorm = max(1, min(10, Int((clima.personalThermalIndex + 10) / 4.0))) 
        let vientoNorm = max(1, min(10, Int(clima.windSpeedKmh / 10.0)))
        let humedadNorm = clima.precipitation == .rainy ? 8 : 3
        
        return DemandaClimatica(
            termica: termicaNorm,
            viento: vientoNorm,
            humedad: humedadNorm,
            requiereProteccionLluvia: clima.precipitation == .rainy
        )
    }
}
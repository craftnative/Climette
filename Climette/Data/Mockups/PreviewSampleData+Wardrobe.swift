#if DEBUG
import Foundation
import SwiftData

@MainActor
extension PreviewSampleData {
    public static func seedWardrobeData(into context: ModelContext) {
        var garmentDescriptor = FetchDescriptor<ClothingItemEntity>()
        garmentDescriptor.fetchLimit = 1
        if let existing = try? context.fetch(garmentDescriptor), !existing.isEmpty {
            return
        }

        let mockGarments: [ClothingItemEntity] = [
            // Torso Superior - Capa Base
            ClothingItemEntity(
                archetypeId: "arch_top_base_cotton_tee",
                canonicalName: "Camiseta manga corta algodón",
                bodyZoneRaw: BodyZone.upperTorso.rawValue,
                layerRaw: ClothingLayer.base.rawValue,
                baseThermal: 2,
                baseWind: 1,
                baseWater: 1,
                userNickname: "Camiseta Básica Blanca",
                color: "Blanco",
                isAvailable: true
            ),
            ClothingItemEntity(
                archetypeId: "arch_top_base_tech_tee",
                canonicalName: "Camiseta técnica transpirable",
                bodyZoneRaw: BodyZone.upperTorso.rawValue,
                layerRaw: ClothingLayer.base.rawValue,
                baseThermal: 1,
                baseWind: 1,
                baseWater: 1,
                userNickname: "Camiseta Running Nike",
                color: "Negro",
                isAvailable: true
            ),
            ClothingItemEntity(
                archetypeId: "arch_top_base_merino_mid",
                canonicalName: "Camiseta térmica lana merino (200g)",
                bodyZoneRaw: BodyZone.upperTorso.rawValue,
                layerRaw: ClothingLayer.base.rawValue,
                baseThermal: 5,
                baseWind: 2,
                baseWater: 2,
                userNickname: "Térmica Merino Icebreaker",
                color: "Gris Carbón",
                isAvailable: true
            ),

            // Torso Superior - Capa Intermedia
            ClothingItemEntity(
                archetypeId: "arch_top_mid_fine_knit",
                canonicalName: "Jersey fino punto algodón",
                bodyZoneRaw: BodyZone.upperTorso.rawValue,
                layerRaw: ClothingLayer.mid.rawValue,
                baseThermal: 3,
                baseWind: 2,
                baseWater: 1,
                userNickname: "Jersey Punto Massimo Dutti",
                color: "Azul Marino",
                isAvailable: true
            ),
            ClothingItemEntity(
                archetypeId: "arch_top_mid_hoodie",
                canonicalName: "Sudadera felpa con capucha",
                bodyZoneRaw: BodyZone.upperTorso.rawValue,
                layerRaw: ClothingLayer.mid.rawValue,
                baseThermal: 4,
                baseWind: 2,
                baseWater: 1,
                userNickname: "Sudadera Gris Capucha",
                color: "Gris Jaspeado",
                isAvailable: true
            ),

            // Torso Superior - Capa Exterior
            ClothingItemEntity(
                archetypeId: "arch_top_outer_rain_jacket",
                canonicalName: "Chubasquero ligero plegable",
                bodyZoneRaw: BodyZone.upperTorso.rawValue,
                layerRaw: ClothingLayer.outer.rawValue,
                baseThermal: 2,
                baseWind: 7,
                baseWater: 9,
                userNickname: "Chubasquero Rains",
                color: "Verde Oliva",
                isAvailable: true
            ),
            ClothingItemEntity(
                archetypeId: "arch_top_outer_denim_jacket",
                canonicalName: "Chaqueta vaquera denim",
                bodyZoneRaw: BodyZone.upperTorso.rawValue,
                layerRaw: ClothingLayer.outer.rawValue,
                baseThermal: 4,
                baseWind: 4,
                baseWater: 1,
                userNickname: "Chaqueta Vaquera Levi's",
                color: "Denim Medio",
                isAvailable: false
            ),
            ClothingItemEntity(
                archetypeId: "arch_top_outer_heavy_puffer",
                canonicalName: "Plumífero grueso de invierno",
                bodyZoneRaw: BodyZone.upperTorso.rawValue,
                layerRaw: ClothingLayer.outer.rawValue,
                baseThermal: 9,
                baseWind: 8,
                baseWater: 4,
                userNickname: "Plumífero North Face",
                color: "Negro",
                isAvailable: true
            ),

            // Piernas / Inferior
            ClothingItemEntity(
                archetypeId: "arch_bot_jeans_standard",
                canonicalName: "Vaquero denim estándar",
                bodyZoneRaw: BodyZone.lowerBody.rawValue,
                layerRaw: nil,
                baseThermal: 4,
                baseWind: 4,
                baseWater: 1,
                userNickname: "Vaqueros 501",
                color: "Azul Claro",
                isAvailable: true
            ),
            ClothingItemEntity(
                archetypeId: "arch_bot_chino_pants",
                canonicalName: "Pantalón chino algodón estándar",
                bodyZoneRaw: BodyZone.lowerBody.rawValue,
                layerRaw: nil,
                baseThermal: 3,
                baseWind: 3,
                baseWater: 1,
                userNickname: "Chino Beige Slim",
                color: "Beige",
                isAvailable: true
            ),
            ClothingItemEntity(
                archetypeId: "arch_bot_running_shorts",
                canonicalName: "Pantalón corto deportivo transpirable",
                bodyZoneRaw: BodyZone.lowerBody.rawValue,
                layerRaw: nil,
                baseThermal: 1,
                baseWind: 1,
                baseWater: 1,
                userNickname: "Short Corto Entrenamiento",
                color: "Azul Marino",
                isAvailable: true
            ),

            // Pies
            ClothingItemEntity(
                archetypeId: "arch_feet_mesh_sneakers",
                canonicalName: "Zapatillas running malla transpirable",
                bodyZoneRaw: BodyZone.feet.rawValue,
                layerRaw: nil,
                baseThermal: 3,
                baseWind: 2,
                baseWater: 1,
                userNickname: "Zapatillas Pegasus",
                color: "Blanco",
                isAvailable: true
            ),
            ClothingItemEntity(
                archetypeId: "arch_feet_leather_boots",
                canonicalName: "Botas de cuero con suela track",
                bodyZoneRaw: BodyZone.feet.rawValue,
                layerRaw: nil,
                baseThermal: 6,
                baseWind: 7,
                baseWater: 5,
                userNickname: "Botas Panama Jack",
                color: "Marrón",
                isAvailable: true
            ),

            // Cabeza / Cuello
            ClothingItemEntity(
                archetypeId: "arch_head_light_beanie",
                canonicalName: "Gorro fino de lana",
                bodyZoneRaw: BodyZone.headNeck.rawValue,
                layerRaw: nil,
                baseThermal: 5,
                baseWind: 4,
                baseWater: 1,
                userNickname: "Gorro Lana Merino",
                color: "Gris Oscuro",
                isAvailable: true
            ),

            // Accesorios
            ClothingItemEntity(
                archetypeId: "arch_acc_storm_umbrella",
                canonicalName: "Paraguas compacto antiviento",
                bodyZoneRaw: BodyZone.accessories.rawValue,
                layerRaw: nil,
                baseThermal: 1,
                baseWind: 3,
                baseWater: 10,
                userNickname: "Paraguas Compacto",
                color: "Negro",
                isAvailable: true
            )
        ]

        for garment in mockGarments {
            context.insert(garment)
        }
    }
}
#endif

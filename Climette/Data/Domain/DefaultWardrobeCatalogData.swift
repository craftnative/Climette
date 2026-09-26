import Foundation
import SwiftData

public enum DefaultWardrobeCatalogData: Sendable {
    
    public static let archetypes: [GarmentArchetype] = [
        // MARK: 1. Torso Superior - Capa Base
        GarmentArchetype(id: "arch_top_base_tank", canonicalName: "Camiseta de tirantes", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_tech_tee", canonicalName: "Camiseta técnica transpirable", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_cotton_tee", canonicalName: "Camiseta manga corta algodón", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 2, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_heavy_tee", canonicalName: "Camiseta algodón pesado (220g)", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 3, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_polo", canonicalName: "Polo manga corta piqué", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 2, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_linen_short", canonicalName: "Camisa lino manga corta", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_linen_long", canonicalName: "Camisa lino manga larga", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 2, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_poplin_shirt", canonicalName: "Camisa popelín manga larga", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_flannel_shirt", canonicalName: "Camisa franela manga larga", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_synth_thermal", canonicalName: "Camiseta térmica ligera sintética", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_merino_mid", canonicalName: "Camiseta térmica lana merino (200g)", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 5, wind: 2, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_merino_heavy", canonicalName: "Camiseta térmica lana merino gruesa (260g)", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 6, wind: 2, water: 2), styleCategory: .neutral),

        // MARK: 2. Torso Superior - Capa Intermedia
        GarmentArchetype(id: "arch_top_mid_light_sweat", canonicalName: "Sudadera cuello redondo ligera", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_hoodie", canonicalName: "Sudadera felpa con capucha", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_fine_knit", canonicalName: "Jersey fino punto algodón", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_merino_knit", canonicalName: "Jersey lana merino fino", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_heavy_wool", canonicalName: "Jersey lana gruesa de ochos", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 6, wind: 3, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_turtleneck", canonicalName: "Jersey cuello alto cisne", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 5, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_microfleece", canonicalName: "Chaqueta forro polar microfibra (100g)", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_fleece_jacket", canonicalName: "Chaqueta forro polar térmico (200g)", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 5, wind: 3, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_sherpa", canonicalName: "Chaqueta polar borreguito Sherpa", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 6, wind: 4, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_down_vest", canonicalName: "Chaleco acolchado plumón ultraligero", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 5, wind: 4, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_wind_vest", canonicalName: "Chaleco polar cortavientos", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 6, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_cardigan", canonicalName: "Cárdigan punto con botones", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .neutral),

        // MARK: 3. Torso Superior - Capa Exterior
        GarmentArchetype(id: "arch_top_outer_overshirt", canonicalName: "Sobrecamisa de pana", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 4, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_denim_jacket", canonicalName: "Chaqueta vaquera denim", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 4, wind: 4, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_bomber", canonicalName: "Chaqueta bomber ligera", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 4, wind: 5, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_leather", canonicalName: "Chaqueta de cuero biker", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 5, wind: 7, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_windbreaker", canonicalName: "Cortavientos running ultraligero", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 2, wind: 8, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_rain_jacket", canonicalName: "Chubasquero ligero plegable", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 2, wind: 7, water: 9), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_trench", canonicalName: "Gabardina clásica Trench", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 4, wind: 6, water: 6), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_softshell", canonicalName: "Chaqueta Softshell cortavientos", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 5, wind: 7, water: 5), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_hardshell", canonicalName: "Chaqueta técnica impermeable Hardshell", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 4, wind: 9, water: 10), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_light_puffer", canonicalName: "Chaqueta acolchada plumón ligera", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 7, wind: 6, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_wool_coat", canonicalName: "Abrigo largo de paño de lana", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 7, wind: 6, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_heavy_puffer", canonicalName: "Plumífero grueso de invierno", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 9, wind: 8, water: 4), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_polar_parka", canonicalName: "Parka polar impermeable con capucha", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 9, wind: 9, water: 8), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_expedition", canonicalName: "Abrigo técnico expedición polar", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 10, wind: 10, water: 9), styleCategory: .neutral),

        // MARK: 4. Piernas / Inferior (Pantalones)
        GarmentArchetype(id: "arch_bot_running_shorts", canonicalName: "Pantalón corto deportivo transpirable", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_chino_shorts", canonicalName: "Bermuda chino algodón", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 2, wind: 1, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_linen_pants", canonicalName: "Pantalón largo de lino", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 2, wind: 2, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_chino_pants", canonicalName: "Pantalón chino algodón estándar", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 3, wind: 3, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_dress_pants", canonicalName: "Pantalón de vestir en lana fría", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 3, wind: 3, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_cargo_pants", canonicalName: "Pantalón cargo ripstop", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 4, wind: 4, water: 2), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_jeans_standard", canonicalName: "Vaquero denim estándar", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 4, wind: 4, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_jeans_heavy", canonicalName: "Vaquero denim pesado (14oz)", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 5, wind: 5, water: 2), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_joggers_fleece", canonicalName: "Pantalón jogger con felpa", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_fleece_lined", canonicalName: "Pantalón con forro polar interior", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 7, wind: 6, water: 2), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_thermal_tights", canonicalName: "Mallas térmicas interiores", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 5, wind: 2, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_rain_overpants", canonicalName: "Sobrepantalón impermeable técnico", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 3, wind: 9, water: 10), styleCategory: .pants),
        
        // MARK: 5. Piernas / Inferior (Faldas)
        GarmentArchetype(id: "arch_bot_skirt_short_light", canonicalName: "Falda corta lino/algodón", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .skirt),
        GarmentArchetype(id: "arch_bot_skirt_midi_denim", canonicalName: "Falda midi denim", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .skirt),
        GarmentArchetype(id: "arch_bot_skirt_heavy_wool", canonicalName: "Falda punto grueso/lana (con medias)", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 5, wind: 4, water: 1), styleCategory: .skirt),
        
        // MARK: 6. Cuerpo Entero (Vestidos)
        GarmentArchetype(id: "arch_full_dress_light", canonicalName: "Vestido ligero tirantes", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .dress),
        GarmentArchetype(id: "arch_full_dress_midi", canonicalName: "Vestido camisero midi", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .dress),
        GarmentArchetype(id: "arch_full_dress_knit", canonicalName: "Vestido de punto grueso", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 6, wind: 3, water: 2), styleCategory: .dress),

        // MARK: 7. Pies
        GarmentArchetype(id: "arch_feet_sandals", canonicalName: "Sandalias abiertas", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_canvas", canonicalName: "Zapatillas de lona ligeras", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 2, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_mesh_sneakers", canonicalName: "Zapatillas running malla transpirable", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_leather_sneakers", canonicalName: "Zapatillas urbanas de piel", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 4, wind: 5, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_oxford", canonicalName: "Zapatos de vestir de cuero", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 4, wind: 5, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_chelsea_boots", canonicalName: "Botines Chelsea de serraje", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 5, wind: 6, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_leather_boots", canonicalName: "Botas de cuero con suela track", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 6, wind: 7, water: 5), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_trail_waterproof", canonicalName: "Zapatillas de montaña membrana impermeable", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 6, wind: 8, water: 8), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_rain_boots", canonicalName: "Botas de agua altas impermeables", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 4, wind: 8, water: 10), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_snow_boots", canonicalName: "Botas de nieve con forro térmico", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 9, wind: 9, water: 8), styleCategory: .neutral),

        // MARK: 8. Cabeza / Cuello
        GarmentArchetype(id: "arch_head_cap", canonicalName: "Gorra con visera de algodón", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 1, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_bucket_rain", canonicalName: "Gorro Bucket impermeable", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 2, wind: 4, water: 7), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_light_beanie", canonicalName: "Gorro fino de lana", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 5, wind: 4, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_heavy_beanie", canonicalName: "Gorro térmico con forro polar", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 7, wind: 6, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_balaclava", canonicalName: "Pasamontañas balaclava térmico", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 8, wind: 8, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_neck_gaiter", canonicalName: "Braga de cuello de microfibra", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 3, wind: 4, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_neck_wool_scarf", canonicalName: "Bufanda de lana punto grueso", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 6, wind: 5, water: 2), styleCategory: .neutral),

        // MARK: 9. Manos y Complementos
        GarmentArchetype(id: "arch_hands_touch_gloves", canonicalName: "Guantes técnicos táctiles finos", bodyZone: .hands, baseProtection: EnvironmentalProtection(thermal: 3, wind: 4, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_hands_leather_gloves", canonicalName: "Guantes de cuero con forro térmico", bodyZone: .hands, baseProtection: EnvironmentalProtection(thermal: 6, wind: 8, water: 4), styleCategory: .neutral),
        GarmentArchetype(id: "arch_acc_storm_umbrella", canonicalName: "Paraguas compacto antiviento", bodyZone: .accessories, baseProtection: EnvironmentalProtection(thermal: 1, wind: 3, water: 10), styleCategory: .neutral)
    ]
    
    public static func defaultWardrobeGarments() -> [Garment] {
        archetypes.map { archetype in
            Garment(
                id: UUID(),
                archetype: archetype,
                userNickname: nil,
                color: nil,
                isAvailable: true
            )
        }
    }

    @MainActor
    public static func seedDatabaseIfNeeded(context: ModelContext) throws {
        var fetchDesc = FetchDescriptor<ClothingItemEntity>()
        fetchDesc.fetchLimit = 1
        let existing = try context.fetch(fetchDesc)
        
        guard existing.isEmpty else { return }
        
        for garment in defaultWardrobeGarments() {
            let entity = ClothingItemEntity(from: garment)
            context.insert(entity)
        }
        try context.save()
    }
}

import Foundation
import SwiftData

public enum DefaultWardrobeCatalogData: Sendable {
    
    public static let archetypes: [GarmentArchetype] = [
        // MARK: 1. Torso Superior - Capa Base
        GarmentArchetype(id: "arch_top_base_tank", canonicalName: "Camiseta de tirantes", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_crop_top", canonicalName: "Top corto básico", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_cotton_tee", canonicalName: "Camiseta manga corta de algodón", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 2, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_oversized_tee", canonicalName: "Camiseta holgada de algodón grueso", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 2, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_long_sleeve_tee", canonicalName: "Camiseta manga larga básica", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_henley", canonicalName: "Camiseta estilo Henley manga larga", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_polo_short", canonicalName: "Polo de piqué manga corta", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 2, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_polo_long", canonicalName: "Polo de manga larga", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_linen_shirt", canonicalName: "Camisa de lino transpirable", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 1, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_short_sleeve_shirt", canonicalName: "Camisa informal de manga corta", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_oxford_shirt", canonicalName: "Camisa clásica Oxford", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_denim_shirt", canonicalName: "Camisa vaquera de chambray o denim ligero", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 4, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_flannel_shirt", canonicalName: "Camisa gruesa de franela", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 4, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_silk_blouse", canonicalName: "Blusa fluida de seda o satén", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 2, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_thermal_light", canonicalName: "Camiseta térmica ligera de microfibra", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_thermal_merino", canonicalName: "Camiseta térmica de lana merina", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 5, wind: 2, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_base_thermal_heavy", canonicalName: "Camiseta térmica gruesa polar", bodyZone: .upperTorso, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 6, wind: 2, water: 2), styleCategory: .neutral),

        // MARK: 2. Torso Superior - Capa Intermedia
        GarmentArchetype(id: "arch_top_mid_fine_knit", canonicalName: "Jersey fino de punto cuello redondo", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_v_neck_knit", canonicalName: "Jersey fino cuello de pico", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_rollneck", canonicalName: "Jersey de cuello alto / cisne", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 5, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_chunky_sweater", canonicalName: "Jersey de lana gruesa trenzada", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 7, wind: 3, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_cardigan", canonicalName: "Chaqueta cárdigan de punto abotonada", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_heavy_cardigan", canonicalName: "Cárdigan grueso de solapa", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 6, wind: 4, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_sweatshirt", canonicalName: "Sudadera básica cuello caja", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_hoodie", canonicalName: "Sudadera con capucha", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_zip_hoodie", canonicalName: "Sudadera con cremallera y capucha", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_quarter_zip", canonicalName: "Jersey o forro con media cremallera", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_fleece_jacket", canonicalName: "Chaqueta de forro polar", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 5, wind: 3, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_sherpa_fleece", canonicalName: "Chaqueta de forro polar de borreguillo", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 6, wind: 4, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_puffer_vest", canonicalName: "Chaleco acolchado aislante", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 5, wind: 6, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_fleece_vest", canonicalName: "Chaleco polar sin mangas", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_overshirt", canonicalName: "Sobrecamisa de sarga / shacket", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 4, wind: 4, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_blazer", canonicalName: "Americana estructurada", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 3, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_mid_tweed_blazer", canonicalName: "Americana de tweed de lana", bodyZone: .upperTorso, supportedLayer: .mid, baseProtection: EnvironmentalProtection(thermal: 5, wind: 4, water: 2), styleCategory: .neutral),

        // MARK: 3. Torso Superior - Capa Exterior
        GarmentArchetype(id: "arch_top_outer_denim_jacket", canonicalName: "Cazadora vaquera", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 4, wind: 5, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_sherpa_denim", canonicalName: "Cazadora vaquera con borrego interior", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 6, wind: 6, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_leather_jacket", canonicalName: "Chaqueta de cuero", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 5, wind: 8, water: 4), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_bomber", canonicalName: "Cazadora bomber clásica", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 4, wind: 6, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_harrington", canonicalName: "Chaqueta ligera tipo Harrington", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 3, wind: 6, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_trench_coat", canonicalName: "Gabardina clásica", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 4, wind: 7, water: 7), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_windbreaker", canonicalName: "Cortavientos ultraligero", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 2, wind: 8, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_rain_jacket", canonicalName: "Chubasquero impermeable técnico", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 2, wind: 7, water: 9), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_poncho_rain", canonicalName: "Poncho impermeable ligero", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 1, wind: 6, water: 9), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_softshell", canonicalName: "Chaqueta softshell cortavientos", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 5, wind: 8, water: 6), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_hardshell", canonicalName: "Chaqueta hardshell de membrana técnica", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 3, wind: 10, water: 10), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_wool_coat", canonicalName: "Abrigo sastre de lana", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 8, wind: 6, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_peacoat", canonicalName: "Chaquetón marinero de lana gruesa", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 8, wind: 7, water: 4), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_duffle_coat", canonicalName: "Trenca clásica con capucha", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 8, wind: 7, water: 4), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_shearling_jacket", canonicalName: "Abrigo de piel de oveja vuelta / shearling", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 9, wind: 8, water: 4), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_light_puffer", canonicalName: "Chaqueta acolchada ligera empacable", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 6, wind: 6, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_heavy_puffer", canonicalName: "Plumífero grueso de invierno", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 9, wind: 8, water: 4), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_parka_waterproof", canonicalName: "Parka técnica impermeable con capucha", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 9, wind: 9, water: 8), styleCategory: .neutral),
        GarmentArchetype(id: "arch_top_outer_expedition_parka", canonicalName: "Parka polar para frío extremo", bodyZone: .upperTorso, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 10, wind: 10, water: 8), styleCategory: .neutral),

        // MARK: 4. Piernas / Inferior (Pantalones)
        GarmentArchetype(id: "arch_bot_running_shorts", canonicalName: "Pantalón corto deportivo de tejido técnico", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_shorts", canonicalName: "Pantalón corto tipo bermuda", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_denim_shorts", canonicalName: "Bermudas vaqueras", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 2, wind: 2, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_linen_trousers", canonicalName: "Pantalón fluido de lino", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 2, wind: 1, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_chinos", canonicalName: "Pantalón chino de algodón", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 3, wind: 3, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_leggings", canonicalName: "Mallas deportivas elásticas", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_joggers", canonicalName: "Pantalón jogger afelpado", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_jeans", canonicalName: "Pantalón vaquero estándar", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 4, wind: 4, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_corduroy_pants", canonicalName: "Pantalón de pana", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 5, wind: 4, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_cargo_pants", canonicalName: "Pantalón cargo resistente", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 4, wind: 5, water: 2), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_trekking_pants", canonicalName: "Pantalón técnico de senderismo", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 4, wind: 6, water: 5), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_wool_trousers", canonicalName: "Pantalón de vestir de lana", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 6, wind: 4, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_thermal_tights", canonicalName: "Mallas térmicas interiores", bodyZone: .lowerBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 6, wind: 2, water: 1), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_fleece_lined_trousers", canonicalName: "Pantalón forrado con tejido polar", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 7, wind: 6, water: 3), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_rain_overpants", canonicalName: "Sobrepantalón impermeable", bodyZone: .lowerBody, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 3, wind: 9, water: 10), styleCategory: .pants),
        GarmentArchetype(id: "arch_bot_ski_pants", canonicalName: "Pantalón aislante de esquí / nieve", bodyZone: .lowerBody, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 9, wind: 9, water: 9), styleCategory: .pants),

        // MARK: 5. Piernas / Inferior (Faldas)
        GarmentArchetype(id: "arch_bot_skirt_light", canonicalName: "Minifalda ligera", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .skirt),
        GarmentArchetype(id: "arch_bot_skirt_denim", canonicalName: "Falda vaquera corta", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 3, wind: 3, water: 1), styleCategory: .skirt),
        GarmentArchetype(id: "arch_bot_skirt_midi", canonicalName: "Falda midi fluida", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .skirt),
        GarmentArchetype(id: "arch_bot_skirt_pencil", canonicalName: "Falda lápiz de sastrería", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 3, wind: 3, water: 1), styleCategory: .skirt),
        GarmentArchetype(id: "arch_bot_skirt_pleated", canonicalName: "Falda plisada larga", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 4, wind: 3, water: 1), styleCategory: .skirt),
        GarmentArchetype(id: "arch_bot_skirt_maxi", canonicalName: "Falda larga hasta los tobillos", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 4, wind: 3, water: 1), styleCategory: .skirt),
        GarmentArchetype(id: "arch_bot_skirt_corduroy", canonicalName: "Falda midi de pana", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 5, wind: 4, water: 1), styleCategory: .skirt),
        GarmentArchetype(id: "arch_bot_skirt_heavy", canonicalName: "Falda de punto grueso o lana", bodyZone: .lowerBody, baseProtection: EnvironmentalProtection(thermal: 5, wind: 4, water: 1), styleCategory: .skirt),

        // MARK: 6. Cuerpo Entero (Vestidos, Monos y Trajes)
        GarmentArchetype(id: "arch_full_dress_slip", canonicalName: "Vestido lencero de satén", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .dress),
        GarmentArchetype(id: "arch_full_dress_light", canonicalName: "Vestido veraniego sin mangas", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .dress),
        GarmentArchetype(id: "arch_full_jumpsuit_light", canonicalName: "Mono corto veraniego", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 2, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_full_dress_shirt", canonicalName: "Vestido camisero de algodón", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .dress),
        GarmentArchetype(id: "arch_full_dress_wrap", canonicalName: "Vestido cruzado de entretiempo", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .dress),
        GarmentArchetype(id: "arch_full_dress_midi", canonicalName: "Vestido midi de manga larga", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .dress),
        GarmentArchetype(id: "arch_full_dress_maxi", canonicalName: "Vestido maxi largo bohemio", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 4, wind: 2, water: 1), styleCategory: .dress),
        GarmentArchetype(id: "arch_full_jumpsuit_denim", canonicalName: "Mono vaquero estructurado", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 4, wind: 4, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_full_overalls", canonicalName: "Peto vaquero clásico", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 4, wind: 4, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_full_dress_heavy", canonicalName: "Vestido de punto de invierno", bodyZone: .fullBody, supportedLayer: .base, baseProtection: EnvironmentalProtection(thermal: 6, wind: 3, water: 2), styleCategory: .dress),
        GarmentArchetype(id: "arch_full_suit_overalls_snow", canonicalName: "Mono térmico integral para nieve", bodyZone: .fullBody, supportedLayer: .outer, baseProtection: EnvironmentalProtection(thermal: 10, wind: 10, water: 9), styleCategory: .neutral),

        // MARK: 7. Pies
        GarmentArchetype(id: "arch_feet_flip_flops", canonicalName: "Chanclas de dedo de goma", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_sandals", canonicalName: "Sandalias abiertas con tiras", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_espadrilles", canonicalName: "Alpargatas de esparto", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 2, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_canvas_shoes", canonicalName: "Zapatillas bajas de lona", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 2, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_sneakers", canonicalName: "Zapatillas deportivas transpirables", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 3, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_leather_sneakers", canonicalName: "Zapatillas urbanas de cuero", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 4, wind: 4, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_loafers", canonicalName: "Mocasines de piel", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 4, wind: 4, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_boat_shoes", canonicalName: "Náuticos clásicos de piel", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 3, wind: 3, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_oxford_shoes", canonicalName: "Zapatos formales Oxford o Derby", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 4, wind: 4, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_chelsea_boots", canonicalName: "Botines Chelsea de cuero", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 5, wind: 6, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_ankle_boots", canonicalName: "Botines con cremallera / cordones", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 5, wind: 5, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_boots", canonicalName: "Botas de trabajo o montaña de piel", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 6, wind: 7, water: 5), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_hiking_boots_tech", canonicalName: "Botas de senderismo con membrana hidrófuga", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 7, wind: 8, water: 8), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_tall_boots", canonicalName: "Botas altas hasta la rodilla", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 7, wind: 7, water: 4), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_winter_insulated_boots", canonicalName: "Botas forradas para nieve", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 9, wind: 8, water: 7), styleCategory: .neutral),
        GarmentArchetype(id: "arch_feet_rain_boots", canonicalName: "Botas altas de agua impermeables", bodyZone: .feet, baseProtection: EnvironmentalProtection(thermal: 4, wind: 8, water: 10), styleCategory: .neutral),

        // MARK: 8. Cabeza / Cuello
        GarmentArchetype(id: "arch_head_cap", canonicalName: "Gorra con visera", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 1, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_sun_hat", canonicalName: "Sombrero de paja de ala ancha", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_visor", canonicalName: "Visera deportiva abierta", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 1, wind: 1, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_bucket_hat", canonicalName: "Gorro de pescador resistente al agua", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 2, wind: 4, water: 6), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_beanie_fine", canonicalName: "Gorro fino de punto de algodón", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 4, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_beanie", canonicalName: "Gorro térmico de lana grueso", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 7, wind: 6, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_trapper_hat", canonicalName: "Gorro ruso tipo ushanka con orejeras", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 9, wind: 8, water: 4), styleCategory: .neutral),
        GarmentArchetype(id: "arch_head_balaclava", canonicalName: "Pasamontañas térmico cortavientos", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 8, wind: 8, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_neck_foulard", canonicalName: "Pañuelo ligero de seda o viscosa", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 2, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_neck_light_scarf", canonicalName: "Bufanda ligera de entretiempo", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 3, wind: 3, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_neck_gaiter", canonicalName: "Braga de cuello técnica cortavientos", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 5, wind: 6, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_neck_fleece_gaiter", canonicalName: "Braga polar de cuello", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 6, wind: 5, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_neck_scarf", canonicalName: "Bufanda gruesa de lana", bodyZone: .headNeck, baseProtection: EnvironmentalProtection(thermal: 6, wind: 5, water: 2), styleCategory: .neutral),

        // MARK: 9. Manos y Accesorios
        GarmentArchetype(id: "arch_hands_light_gloves", canonicalName: "Guantes finos elásticos táctiles", bodyZone: .hands, baseProtection: EnvironmentalProtection(thermal: 3, wind: 4, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_hands_fleece_gloves", canonicalName: "Guantes de forro polar", bodyZone: .hands, baseProtection: EnvironmentalProtection(thermal: 5, wind: 4, water: 2), styleCategory: .neutral),
        GarmentArchetype(id: "arch_hands_leather_gloves", canonicalName: "Guantes de piel cortavientos forrados", bodyZone: .hands, baseProtection: EnvironmentalProtection(thermal: 6, wind: 8, water: 3), styleCategory: .neutral),
        GarmentArchetype(id: "arch_hands_heavy_gloves", canonicalName: "Guantes térmicos impermeables de esquí", bodyZone: .hands, baseProtection: EnvironmentalProtection(thermal: 8, wind: 8, water: 8), styleCategory: .neutral),
        GarmentArchetype(id: "arch_hands_mittens", canonicalName: "Manoplas de expedición de plumas", bodyZone: .hands, baseProtection: EnvironmentalProtection(thermal: 10, wind: 9, water: 7), styleCategory: .neutral),
        GarmentArchetype(id: "arch_acc_sunglasses", canonicalName: "Gafas de sol con protección UV", bodyZone: .accessories, baseProtection: EnvironmentalProtection(thermal: 1, wind: 2, water: 1), styleCategory: .neutral),
        GarmentArchetype(id: "arch_acc_umbrella", canonicalName: "Paraguas compacto plegable", bodyZone: .accessories, baseProtection: EnvironmentalProtection(thermal: 1, wind: 3, water: 10), styleCategory: .neutral),
        GarmentArchetype(id: "arch_acc_storm_umbrella", canonicalName: "Paraguas largo antiviento reforzado", bodyZone: .accessories, baseProtection: EnvironmentalProtection(thermal: 1, wind: 6, water: 10), styleCategory: .neutral),
        GarmentArchetype(id: "arch_acc_earmuffs", canonicalName: "Orejeras térmicas de invierno", bodyZone: .accessories, baseProtection: EnvironmentalProtection(thermal: 5, wind: 5, water: 1), styleCategory: .neutral)
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

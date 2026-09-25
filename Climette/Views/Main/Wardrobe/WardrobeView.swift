import SwiftUI
import SwiftData

struct WardrobeView: View {
    @Query private var clothingEntities: [ClothingItemEntity]
    
    var groupedGarments: [BodyZone: [Garment]] {
        let garments = clothingEntities.map { $0.toDomain() }
        return Dictionary(grouping: garments, by: { $0.archetype.bodyZone })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if clothingEntities.isEmpty {
                    emptyState()
                } else {
                    ForEach(BodyZone.allCases, id: \.self) { zone in
                        if let garmentsInZone = groupedGarments[zone], !garmentsInZone.isEmpty {
                            zoneSection(zone: zone, garments: garmentsInZone)
                        }
                    }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
        .background(Color("BackgroundBase").ignoresSafeArea())
        .navigationTitle(Text("Armario"))
    }
    
    private func emptyState() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "tshirt")
                .font(.system(size: 64))
                .foregroundStyle(Color("AccentColor"))
                .accessibilityHidden(true)

            Text("wardrobe_empty_title")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color("TextPrimary"))

            Text("wardrobe_empty_description")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("TextSecondary"))
                .padding(.horizontal, 32)
        }
        .padding(.top, 48)
        .accessibilityElement(children: .combine)
    }
    
    private func zoneSection(zone: BodyZone, garments: [Garment]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(zone.rawValue)
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))
                .padding(.horizontal)
            
            ForEach(garments) { garment in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(garment.resolvedDisplayName)
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color("TextPrimary"))
                        
                        HStack(spacing: 8) {
                            metricBadge(icon: "thermometer", value: garment.effectiveProtection.thermal, isOverride: garment.overrideThermal != nil)
                            metricBadge(icon: "wind", value: garment.effectiveProtection.wind, isOverride: garment.overrideWind != nil)
                            metricBadge(icon: "drop.fill", value: garment.effectiveProtection.water, isOverride: garment.overrideWater != nil)
                        }
                    }
                    Spacer()
                    if !garment.isAvailable {
                        Text("No disponible")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .background(Color("SurfaceElevated"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }
    
    private func metricBadge(icon: String, value: Int, isOverride: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text("\(value)/10")
        }
        .font(.caption2.weight(.semibold))
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(isOverride ? Color("AccentColor").opacity(0.2) : Color.secondary.opacity(0.1))
        .foregroundStyle(isOverride ? Color("AccentColor") : Color("TextSecondary"))
        .clipShape(Capsule())
    }
}

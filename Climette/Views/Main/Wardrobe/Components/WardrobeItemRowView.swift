import SwiftUI

struct WardrobeItemRowView: View {
    let garment: Garment

    var body: some View {
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

    private func metricBadge(icon: String, value: Int, isOverride: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(verbatim: "\(value)/10")
        }
        .font(.caption2.weight(.semibold))
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(isOverride ? Color("AccentColor").opacity(0.2) : Color.secondary.opacity(0.1))
        .foregroundStyle(isOverride ? Color("AccentColor") : Color("TextSecondary"))
        .clipShape(Capsule())
    }
}

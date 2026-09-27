import SwiftUI

struct GarmentRowView: View {
    let zone: BodyZone
    let garment: Garment

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            HStack(spacing: 6) {
                Text(shortZoneName(for: zone))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("TextSecondary"))

                if let layer = garment.archetype.supportedLayer {
                    Text(layer.rawValue)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .frame(width: 120, alignment: .trailing)

            Rectangle()
                .fill(Color("SeparatorBase"))
                .frame(width: 1, height: 16)

            Text(garment.resolvedDisplayName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("TextPrimary"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 8)
    }

    private func shortZoneName(for zone: BodyZone) -> String {
        let raw = zone.rawValue.lowercased()
        if raw.contains("cabeza") { return "Cabeza" }
        if raw.contains("superior") || raw.contains("torso") { return "Torso" }
        if raw.contains("cuerpo") || raw.contains("vestido") { return "Cuerpo Entero" }
        if raw.contains("inferior") || raw.contains("pierna") { return "Piernas" }
        if raw.contains("pie") || raw.contains("calzado") { return "Calzado" }
        if raw.contains("comple") || raw.contains("accesor") { return "Accesorios" }
        return zone.rawValue
    }
}

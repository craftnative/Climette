import SwiftUI
import SwiftData

public struct RecommendationSnippetView: View {
    public let outfit: Outfit
    public let headline: String
    public let notice: String?

    public init(outfit: Outfit, headline: String, notice: String? = nil) {
        self.outfit = outfit
        self.headline = headline
        self.notice = notice
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(headline)
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))
            
            if let notice = notice {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color("AccentColor"))
                    Text(notice)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color("TextPrimary"))
                }
                .padding(10)
                .background(Color("AccentColor").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Divider()
                .background(Color("SeparatorBase"))
            
            ForEach(BodyZone.allCases, id: \.self) { zone in
                if let garments = outfit.garmentsByZone[zone], !garments.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(zone.rawValue.uppercased())
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color("TextSecondary"))
                        
                        ForEach(garments) { garment in
                            Text("• \(garment.resolvedDisplayName)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color("TextPrimary"))
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
        .padding()
        .background(Color("SurfaceElevated"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

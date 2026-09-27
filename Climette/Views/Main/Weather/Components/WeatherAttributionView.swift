import SwiftUI
import WeatherKit

struct WeatherAttributionView: View {
    let attribution: WeatherAttribution
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Link(destination: attribution.legalPageURL) {
            AsyncImage(url: colorScheme == .dark ? attribution.combinedMarkDarkURL : attribution.combinedMarkLightURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 15)
            } placeholder: {
                Text("Datos de Apple Weather")
                    .font(.caption)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
}

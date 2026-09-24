import SwiftUI

struct WeatherView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color("BrandWarmth"))
                        .accessibilityHidden(true)

                    Text("weather_empty_title")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color("TextPrimary"))

                    Text("weather_empty_description")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("TextSecondary"))
                        .padding(.horizontal, 32)
                }
                .padding(.top, 48)
                .accessibilityElement(children: .combine)
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color("BackgroundBase").ignoresSafeArea())
        .navigationTitle(Text("Tiempo"))
    }
}

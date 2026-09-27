import SwiftUI

struct WeatherHeaderView: View {
    let cityName: String

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(cityName)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("TextPrimary"))

            Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))
                .textCase(.uppercase)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

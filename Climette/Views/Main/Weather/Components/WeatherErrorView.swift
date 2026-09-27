import SwiftUI

struct WeatherErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)

            Text(message)
                .font(.body)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 48)
    }
}

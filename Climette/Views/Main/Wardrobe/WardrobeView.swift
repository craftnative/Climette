import SwiftUI

struct WardrobeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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
            .frame(maxWidth: .infinity)
        }
        .background(Color("BackgroundBase").ignoresSafeArea())
        .navigationTitle(Text("Armario"))
    }
}

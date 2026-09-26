import SwiftUI

struct WardrobeEmptyStateView: View {
    let isSearch: Bool
    let searchText: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: isSearch ? "magnifyingglass" : "tshirt")
                .font(.system(size: 64))
                .foregroundStyle(Color("AccentColor"))
                .accessibilityHidden(true)

            Text(isSearch ? "Sin resultados" : "wardrobe_empty_title")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color("TextPrimary"))

            if isSearch {
                Text("No se encontraron resultados para: \(searchText)")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("TextSecondary"))
                    .padding(.horizontal, 32)
            } else {
                Text("wardrobe_empty_description")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("TextSecondary"))
                    .padding(.horizontal, 32)
            }
        }
        .padding(.top, 48)
        .accessibilityElement(children: .combine)
    }
}

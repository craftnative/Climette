import SwiftUI

struct WardrobeSectionView: View {
    let zone: BodyZone
    let garments: [Garment]
    
    @State private var isExpanded: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(zone.rawValue)
                        .font(.headline)
                        .foregroundStyle(Color("TextPrimary"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color("TextSecondary"))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(garments) { garment in
                        WardrobeItemRowView(garment: garment)
                    }
                }
            }
        }
    }
}

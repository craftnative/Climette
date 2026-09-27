import SwiftUI
import SwiftData

struct WardrobeSectionView: View {
    let zone: BodyZone
    let entities: [ClothingItemEntity]
    let onEdit: (ClothingItemEntity) -> Void
    
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
                    
                    Text("\(entities.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("TextSecondary"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color("SeparatorBase").opacity(0.3))
                        .clipShape(Capsule())
                    
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
                    ForEach(entities) { entity in
                        Button {
                            onEdit(entity)
                        } label: {
                            WardrobeItemRowView(garment: entity.toDomain())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

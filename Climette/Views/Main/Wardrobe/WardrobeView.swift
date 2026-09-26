import SwiftUI
import SwiftData

struct WardrobeView: View {
    @Query private var clothingEntities: [ClothingItemEntity]
    @State private var searchText: String = ""
    
    var filteredGarments: [Garment] {
        let garments = clothingEntities.map { $0.toDomain() }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return garments
        } else {
            return garments.filter {
                $0.resolvedDisplayName.localizedCaseInsensitiveContains(query) ||
                $0.archetype.bodyZone.rawValue.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    var groupedGarments: [BodyZone: [Garment]] {
        Dictionary(grouping: filteredGarments, by: { $0.archetype.bodyZone })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if clothingEntities.isEmpty {
                    WardrobeEmptyStateView(isSearch: false, searchText: "")
                } else if filteredGarments.isEmpty {
                    WardrobeEmptyStateView(isSearch: true, searchText: searchText)
                } else {
                    ForEach(BodyZone.allCases, id: \.self) { zone in
                        if let garmentsInZone = groupedGarments[zone], !garmentsInZone.isEmpty {
                            WardrobeSectionView(zone: zone, garments: garmentsInZone)
                        }
                    }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
        .searchable(text: $searchText, prompt: "Buscar prenda")
        .background(Color("BackgroundBase").ignoresSafeArea())
        .navigationTitle(Text("Armario"))
    }
}

import SwiftUI
import SwiftData

struct GarmentCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText: String = ""
    @State private var selectedArchetype: GarmentArchetype?
    
    let archetypes = DefaultWardrobeCatalogData.archetypes
    
    var filteredArchetypes: [GarmentArchetype] {
        if searchText.isEmpty {
            return archetypes
        }
        return archetypes.filter {
            $0.canonicalName.localizedCaseInsensitiveContains(searchText) ||
            $0.bodyZone.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var groupedArchetypes: [BodyZone: [GarmentArchetype]] {
        Dictionary(grouping: filteredArchetypes, by: { $0.bodyZone })
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(BodyZone.allCases, id: \.self) { zone in
                    if let group = groupedArchetypes[zone], !group.isEmpty {
                        Section(header: Text(zone.rawValue)) {
                            ForEach(group) { archetype in
                                Button {
                                    createEntity(from: archetype)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(archetype.canonicalName)
                                                .font(.body.weight(.medium))
                                                .foregroundStyle(Color("TextPrimary"))
                                            
                                            HStack(spacing: 6) {
                                                metricMini(icon: "thermometer", value: archetype.baseProtection.thermal)
                                                metricMini(icon: "wind", value: archetype.baseProtection.wind)
                                                metricMini(icon: "drop.fill", value: archetype.baseProtection.water)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "plus.circle")
                                            .foregroundStyle(Color("AccentColor"))
                                            .font(.title3)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Buscar tipo de prenda")
            .navigationTitle("Nueva Prenda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
    
    private func metricMini(icon: String, value: Int) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
            Text("\(value)")
        }
        .font(.caption2)
        .foregroundStyle(Color("TextSecondary"))
    }
    
    private func createEntity(from archetype: GarmentArchetype) {
        let domainGarment = Garment(archetype: archetype)
        let newEntity = ClothingItemEntity(from: domainGarment)
        
        modelContext.insert(newEntity)
        try? modelContext.save()
        dismiss()
    }
}

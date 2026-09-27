import SwiftUI
import SwiftData
import Foundation

struct WardrobeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var clothingEntities: [ClothingItemEntity]
    
    @State private var searchText: String = ""
    @State private var filterConfig = WardrobeFilterConfig()
    @State private var isShowingCreator: Bool = false
    @State private var isShowingFilters: Bool = false
    @State private var editingEntity: ClothingItemEntity?
    
    var filteredEntities: [ClothingItemEntity] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return clothingEntities.filter { entity in
            if !query.isEmpty {
                let matchesSearch = entity.canonicalName.localizedCaseInsensitiveContains(query) ||
                    (entity.userNickname?.localizedCaseInsensitiveContains(query) == true) ||
                    entity.bodyZoneRaw.localizedCaseInsensitiveContains(query)
                guard matchesSearch else { return false }
            }
            
            if !filterConfig.selectedZones.isEmpty {
                guard let zone = BodyZone(rawValue: entity.bodyZoneRaw),
                      filterConfig.selectedZones.contains(zone) else {
                    return false
                }
            }
            
            let thermal = Double(entity.overrideThermal ?? entity.baseThermal)
            let wind = Double(entity.overrideWind ?? entity.baseWind)
            let rain = Double(entity.overrideWater ?? entity.baseWater)
            
            guard thermal >= filterConfig.minThermal,
                  wind >= filterConfig.minWind,
                  rain >= filterConfig.minRain else {
                return false
            }
            
            return true
        }
    }
    
    var groupedEntities: [String: [ClothingItemEntity]] {
        Dictionary(grouping: filteredEntities, by: { $0.bodyZoneRaw })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if clothingEntities.isEmpty {
                    WardrobeEmptyStateView(isSearch: false, searchText: "")
                } else if filteredEntities.isEmpty {
                    WardrobeEmptyStateView(isSearch: true, searchText: searchText)
                } else {
                    ForEach(BodyZone.allCases, id: \.self) { zone in
                        if let entitiesInZone = groupedEntities[zone.rawValue], !entitiesInZone.isEmpty {
                            WardrobeSectionView(
                                zone: zone,
                                entities: entitiesInZone,
                                onEdit: { entity in
                                    editingEntity = entity
                                }
                            )
                        }
                    }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: Text("Buscar prenda")
        )
        .background(Color("BackgroundBase").ignoresSafeArea())
        .navigationTitle(Text("Armario"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isShowingFilters = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .fontWeight(.semibold)
                        
                        if !filterConfig.isDefault {
                            Circle()
                                .fill(Color("AccentColor"))
                                .frame(width: 8, height: 8)
                                .offset(x: 2, y: -2)
                        }
                    }
                }
                .accessibilityLabel("Filtrar prendas")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingCreator = true
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
                .accessibilityLabel("Añadir nueva prenda")
            }
        }
        .sheet(isPresented: $isShowingFilters) {
            WardrobeFilterView(filterConfig: $filterConfig)
        }
        .sheet(isPresented: $isShowingCreator) {
            GarmentCreatorView()
        }
        .sheet(item: $editingEntity) { entity in
            GarmentEditorView(entity: entity)
        }
    }
}

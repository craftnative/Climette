import SwiftUI
import SwiftData

private struct GarmentReplacementContext: Identifiable {
    var id: UUID { garment.id }
    let garment: ClothingItemEntity
}

struct FeedbackEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let recordEntity: FeedbackRecordEntity
    let isEligibleForEdit: Bool
    let initialEditMode: Bool
    
    @Query(sort: \ClothingItemEntity.canonicalName)
    private var allCatalogGarments: [ClothingItemEntity]
    
    @State private var isEditing: Bool
    @State private var didWork: Bool = true
    @State private var failureReason: ThermalPerception = .feltCold
    @State private var isIndoorDistortion: Bool = false
    
    @State private var currentGarments: [ClothingItemEntity] = []
    @State private var isShowingAddSheet: Bool = false
    @State private var garmentToReplaceContext: GarmentReplacementContext?

    init(recordEntity: FeedbackRecordEntity, isEligibleForEdit: Bool, initialEditMode: Bool = false) {
        self.recordEntity = recordEntity
        self.isEligibleForEdit = isEligibleForEdit
        self.initialEditMode = isEligibleForEdit && initialEditMode
        self._isEditing = State(initialValue: isEligibleForEdit && initialEditMode)
    }

    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                evaluationSection
                garmentsSection
            }
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundBase").ignoresSafeArea())
            .navigationTitle(isEditing ? Text("Editar registro") : Text("Detalle del registro"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    leadingToolbarItem
                }
                ToolbarItem(placement: .topBarTrailing) {
                    trailingToolbarItem
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                GarmentSelectionSheet(
                    title: "Añadir prenda",
                    availableGarments: availableGarmentsToAdd
                ) { selected in
                    currentGarments.append(selected)
                }
            }
            .sheet(item: $garmentToReplaceContext) { context in
                let target = context.garment
                GarmentSelectionSheet(
                    title: "Cambiar \(target.canonicalName)",
                    availableGarments: availableGarmentsToReplace(target)
                ) { selected in
                    if let index = currentGarments.firstIndex(where: { $0.id == target.id }) {
                        currentGarments[index] = selected
                    }
                }
            }
            .onAppear {
                loadRecordData()
            }
        }
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section {
            detailRow(
                icon: "calendar",
                title: "Fecha",
                value: recordEntity.timestamp.formatted(.dateTime.day().month(.wide).year())
            )
            
            detailRow(
                icon: "clock",
                title: "Hora registrada",
                value: recordEntity.timestamp.formatted(.dateTime.hour().minute())
            )
            
            if let weather = recordEntity.weatherSnapshot {
                detailRow(
                    icon: "thermometer.medium",
                    title: "Temperatura",
                    value: String(format: "%.1f°C", weather.temperature)
                )
                
                if let hum = weather.humidity {
                    detailRow(
                        icon: "humidity.fill",
                        title: "Humedad relativa",
                        value: String(format: "%.0f%%", hum)
                    )
                }
                
                detailRow(
                    icon: "wind",
                    title: "Velocidad del viento",
                    value: String(format: "%.1f km/h", weather.windSpeedKmh)
                )
                
                let isRain = weather.precipitationRaw == PrecipitationState.rainy.rawValue
                detailRow(
                    icon: isRain ? "cloud.rain.fill" : "sun.max.fill",
                    title: "Precipitación",
                    value: isRain ? "Lluvia registrada" : "Sin lluvia"
                )
            }
        } header: {
            Text("Condiciones meteorológicas")
        }
        .listRowBackground(Color("SurfaceElevated"))
    }
    
    @ViewBuilder
    private var evaluationSection: some View {
        Section {
            if isEditing {
                Picker("¿Funcionó la recomendación?", selection: $didWork) {
                    Text("Funcionó").tag(true)
                    Text("No funcionó").tag(false)
                }
                .pickerStyle(.segmented)
                
                if !didWork {
                    Picker("Sensación experimentada", selection: $failureReason) {
                        Text(ThermalPerception.feltCold.rawValue).tag(ThermalPerception.feltCold)
                        Text(ThermalPerception.feltHot.rawValue).tag(ThermalPerception.feltHot)
                    }
                    .pickerStyle(.menu)
                    
                    Toggle("Distorsión por interiores", isOn: $isIndoorDistortion)
                }
            } else {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color("AccentColor").opacity(0.12))
                            .frame(width: 32, height: 32)
                        Image(systemName: didWork ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("AccentColor"))
                    }
                    
                    Text("Resultado")
                        .foregroundStyle(Color("TextSecondary"))
                    
                    Spacer()
                    
                    Text(didWork ? "Funcionó" : "No funcionó")
                        .foregroundStyle(Color("TextPrimary"))
                        .fontWeight(.semibold)
                }
                
                if !didWork {
                    detailRow(
                        icon: failureReason == .feltCold ? "snowflake" : "flame.fill",
                        title: "Sensación",
                        value: failureReason.rawValue
                    )
                    
                    detailRow(
                        icon: "building.2.fill",
                        title: "Distorsión por interiores",
                        value: isIndoorDistortion ? "Sí" : "No"
                    )
                }
            }
        } header: {
            Text("Evaluación de la recomendación")
        }
        .listRowBackground(Color("SurfaceElevated"))
    }
    
    @ViewBuilder
    private var garmentsSection: some View {
        Section {
            if currentGarments.isEmpty {
                Text("No hay prendas registradas para este atuendo.")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            } else {
                ForEach(currentGarments, id: \.id) { garment in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color("AccentColor").opacity(0.12))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: iconForGarmentZone(garment.bodyZoneRaw))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color("AccentColor"))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(garment.canonicalName)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color("TextPrimary"))
                            
                            Text(garment.bodyZoneRaw.capitalized)
                                .font(.caption2)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                        
                        Spacer()
                        
                        if isEditing {
                            Button {
                                garmentToReplaceContext = GarmentReplacementContext(garment: garment)
                            } label: {
                                Text("Cambiar")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color("AccentColor"))
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onDelete(perform: isEditing ? { offsets in removeGarments(at: offsets) } : nil)
            }
            
            if isEditing {
                Button {
                    isShowingAddSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Añadir prenda")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AccentColor"))
                }
            }
        } header: {
            Text("Ropa vestida")
        } footer: {
            if isEditing {
                Text("Desliza hacia la izquierda sobre una prenda para eliminarla o pulsa Cambiar para sustituirla.")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            }
        }
        .listRowBackground(Color("SurfaceElevated"))
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color("AccentColor").opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("AccentColor"))
            }
            
            Text(title)
                .font(.body)
                .foregroundStyle(Color("TextSecondary"))
            
            Spacer()
            
            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(Color("TextPrimary"))
        }
        .padding(.vertical, 2)
    }
    
    private func iconForGarmentZone(_ zone: String) -> String {
        let normalized = zone.lowercased()
        if normalized.contains("cabeza") || normalized.contains("head") {
            return "hat.widebrim.fill"
        } else if normalized.contains("inferior") || normalized.contains("piernas") || normalized.contains("legs") || normalized.contains("lower") {
            return "figure.walk"
        } else if normalized.contains("pies") || normalized.contains("calzado") || normalized.contains("feet") || normalized.contains("shoes") {
            return "shoeprints.fill"
        } else if normalized.contains("manos") || normalized.contains("hands") {
            return "hand.raised.fill"
        } else {
            return "tshirt.fill"
        }
    }
    
    @ViewBuilder
    private var leadingToolbarItem: some View {
        if isEditing {
            Button("Cancelar") {
                if initialEditMode {
                    dismiss()
                } else {
                    loadRecordData()
                    withAnimation {
                        isEditing = false
                    }
                }
            }
        } else if isEligibleForEdit {
            Button("Editar") {
                withAnimation {
                    isEditing = true
                }
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(Color("AccentColor"))
        }
    }
    
    @ViewBuilder
    private var trailingToolbarItem: some View {
        if isEditing {
            Button("Listo") {
                saveChanges()
                dismiss()
            }
            .font(.headline)
            .foregroundStyle(Color("AccentColor"))
        } else {
            Button("Cerrar") {
                dismiss()
            }
        }
    }
    
    private var availableGarmentsToAdd: [ClothingItemEntity] {
        let currentIds = Set(currentGarments.map(\.id))
        return allCatalogGarments.filter { !currentIds.contains($0.id) }
    }
    
    private func availableGarmentsToReplace(_ target: ClothingItemEntity) -> [ClothingItemEntity] {
        let currentIds = Set(currentGarments.map(\.id))
        return allCatalogGarments.filter { garment in
            garment.bodyZoneRaw == target.bodyZoneRaw && !currentIds.contains(garment.id)
        }
    }
    
    private func removeGarments(at offsets: IndexSet) {
        currentGarments.remove(atOffsets: offsets)
    }
    
    private func loadRecordData() {
        let initialPerception = ThermalPerception(rawValue: recordEntity.perceptionRaw) ?? .perfect
        let initialState = DailyCollectionState(rawValue: recordEntity.collectionStateRaw) ?? .correct
        
        if initialState == .correct && initialPerception == .perfect {
            didWork = true
            failureReason = .feltCold
        } else {
            didWork = false
            failureReason = (initialPerception == .feltHot) ? .feltHot : .feltCold
        }
        
        isIndoorDistortion = recordEntity.isIndoorDistortion
        currentGarments = recordEntity.wornGarments ?? []
    }
    
    private func saveChanges() {
        if didWork {
            recordEntity.collectionStateRaw = DailyCollectionState.correct.rawValue
            recordEntity.perceptionRaw = ThermalPerception.perfect.rawValue
            recordEntity.isIndoorDistortion = false
        } else {
            recordEntity.collectionStateRaw = DailyCollectionState.adjusted.rawValue
            recordEntity.perceptionRaw = failureReason.rawValue
            recordEntity.isIndoorDistortion = isIndoorDistortion
        }
        
        let initialGarments = recordEntity.wornGarments ?? []
        let hasOutfitChanged = Set(initialGarments.map(\.id)) != Set(currentGarments.map(\.id))
        
        recordEntity.wornGarments = currentGarments
        
        if hasOutfitChanged {
            recordEntity.physicalReactionRaw = PhysicalReaction.adjustedClothing.rawValue
            if let firstAdded = currentGarments.first(where: { garment in
                !initialGarments.contains(where: { $0.id == garment.id })
            }) {
                recordEntity.adjustedGarment = firstAdded
            }
        }
        
        try? modelContext.save()
    }
}

private struct GarmentSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let availableGarments: [ClothingItemEntity]
    let onSelect: (ClothingItemEntity) -> Void
    
    @State private var searchText: String = ""
    
    private var filteredGarments: [ClothingItemEntity] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return availableGarments
        }
        return availableGarments.filter {
            $0.canonicalName.localizedCaseInsensitiveContains(searchText) ||
            $0.bodyZoneRaw.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredGarments, id: \.id) { garment in
                Button {
                    onSelect(garment)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(garment.canonicalName)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color("TextPrimary"))
                            
                            Text(garment.bodyZoneRaw.capitalized)
                                .font(.caption)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                        Spacer()
                        Image(systemName: "plus.circle")
                            .foregroundStyle(Color("AccentColor"))
                    }
                }
                .listRowBackground(Color("SurfaceElevated"))
            }
            .searchable(text: $searchText, prompt: "Buscar prenda")
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundBase").ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

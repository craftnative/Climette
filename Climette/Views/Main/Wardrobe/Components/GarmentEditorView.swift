import SwiftUI
import SwiftData

struct GarmentEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allClothingEntities: [ClothingItemEntity]
    
    let entity: ClothingItemEntity
    
    @State private var nickname: String = ""
    @State private var isAvailable: Bool = true
    
    @State private var customizeProtection: Bool = false
    @State private var overrideThermal: Double = 1
    @State private var overrideWind: Double = 1
    @State private var overrideWater: Double = 1
    
    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Arquetipo base", value: entity.canonicalName)
                        .foregroundStyle(Color("TextSecondary"))
                    
                    TextField("Apodo personalizado (Opcional)", text: $nickname)
                        .textInputAutocapitalization(.words)
                    
                    Toggle("Disponible en el armario", isOn: $isAvailable)
                        .tint(Color("AccentColor"))
                } header: {
                    Text("Detalles de la prenda")
                }
                
                Section {
                    Toggle("Personalizar aislamiento", isOn: $customizeProtection.animation())
                        .tint(Color("AccentColor"))
                    
                    if customizeProtection {
                        protectionSlider(title: "Abrigo Térmico", value: $overrideThermal, icon: "thermometer")
                        protectionSlider(title: "Cortavientos", value: $overrideWind, icon: "wind")
                        protectionSlider(title: "Impermeabilidad", value: $overrideWater, icon: "drop.fill")
                    }
                } header: {
                    Text("Propiedades climáticas")
                } footer: {
                    Text("Ajusta estos valores si tu prenda abriga, corta el viento o repele el agua de forma distinta al estándar de su categoría.")
                }
                
                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Eliminar prenda")
                            Spacer()
                        }
                    }
                    .disabled(!canDelete)
                } footer: {
                    if !canDelete {
                        Text("No puedes eliminar esta prenda porque es la única registrada para la zona: \(entity.bodyZoneRaw). Debe existir al menos una alternativa funcional.")
                            .foregroundStyle(.red)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundBase").ignoresSafeArea())
            .navigationTitle("Editar Prenda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { saveChanges() }
                        .fontWeight(.bold)
                        .foregroundStyle(Color("AccentColor"))
                }
            }
            .onAppear(perform: loadCurrentState)
            .confirmationDialog("¿Eliminar prenda?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Eliminar permanentemente", role: .destructive) {
                    deleteEntity()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Esta acción eliminará la prenda de tu armario de forma irreversible.")
            }
        }
    }
    
    private var canDelete: Bool {
        let sameZoneCount = allClothingEntities.filter { $0.bodyZoneRaw == entity.bodyZoneRaw }.count
        return sameZoneCount > 1
    }
    
    private func protectionSlider(title: String, value: Binding<Double>, icon: String) -> some View {
        VStack(spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                Text("\(Int(value.wrappedValue))/10")
                    .fontWeight(.bold)
                    .foregroundStyle(Color("AccentColor"))
            }
            Slider(value: value, in: 1...10, step: 1)
                .tint(Color("AccentColor"))
        }
        .padding(.vertical, 4)
    }
    
    private func loadCurrentState() {
        nickname = entity.userNickname ?? ""
        isAvailable = entity.isAvailable
        
        let hasOverrides = entity.overrideThermal != nil || entity.overrideWind != nil || entity.overrideWater != nil
        customizeProtection = hasOverrides
        
        overrideThermal = Double(entity.overrideThermal ?? entity.baseThermal)
        overrideWind = Double(entity.overrideWind ?? entity.baseWind)
        overrideWater = Double(entity.overrideWater ?? entity.baseWater)
    }
    
    private func saveChanges() {
        entity.userNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : nickname
        entity.isAvailable = isAvailable
        
        if customizeProtection {
            entity.overrideThermal = Int(overrideThermal)
            entity.overrideWind = Int(overrideWind)
            entity.overrideWater = Int(overrideWater)
        } else {
            entity.overrideThermal = nil
            entity.overrideWind = nil
            entity.overrideWater = nil
        }
        
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteEntity() {
        guard canDelete else { return }
        modelContext.delete(entity)
        try? modelContext.save()
        dismiss()
    }
}

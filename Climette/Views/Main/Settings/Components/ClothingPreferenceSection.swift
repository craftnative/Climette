import SwiftUI
import SwiftData

struct ClothingPreferenceSection: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var userProfile: UserProfileEntity
    
    @State private var localPreference: ClothingPreference = .both
    
    var body: some View {
        Section {
            Picker("Estilo", selection: $localPreference) {
                ForEach(ClothingPreference.allCases, id: \.self) { pref in
                    Text(LocalizedStringKey(pref.rawValue)).tag(pref)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: localPreference) { _, newValue in
                userProfile.clothingPreferenceRaw = newValue.rawValue
                userProfile.updatedAt = .now
                do {
                    try modelContext.save()
                } catch {
                    print("Error saving clothing preference: \(error)")
                }
            }
        } header: {
            VStack(alignment: .leading, spacing: 4) {
                Text("Preferencia de prendas")
                Text("Ajusta si prefieres pantalones, faldas/vestidos, o ambos.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listRowBackground(Color("SurfaceElevated"))
        .onAppear {
            localPreference = ClothingPreference(rawValue: userProfile.clothingPreferenceRaw) ?? .both
        }
    }
}

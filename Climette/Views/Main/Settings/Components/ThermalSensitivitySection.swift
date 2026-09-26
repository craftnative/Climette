import SwiftUI
import SwiftData

struct ThermalSensitivitySection: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var userProfile: UserProfileEntity
    
    @State private var localSensitivity: ThermalSensitivity = .normal
    
    var body: some View {
        Section {
            Picker("Sensibilidad", selection: $localSensitivity) {
                ForEach(ThermalSensitivity.allCases, id: \.self) { sensitivity in
                    Text(LocalizedStringKey(sensitivity.rawValue)).tag(sensitivity)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: localSensitivity) { _, newValue in
                userProfile.sensitivityRaw = newValue.rawValue
                userProfile.updatedAt = .now
                do {
                    try modelContext.save()
                } catch {
                    print("Error saving thermal sensitivity: \(error)")
                }
            }
            
            Text(description(for: localSensitivity))
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
        } header: {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sensibilidad Térmica")
                Text("Calibra cómo percibes las variaciones de temperatura para ajustar tu Índice Térmico Personalizado.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listRowBackground(Color("SurfaceElevated"))
        .onAppear {
            localSensitivity = ThermalSensitivity(rawValue: userProfile.sensitivityRaw) ?? .normal
        }
    }
    
    private func description(for sensitivity: ThermalSensitivity) -> LocalizedStringKey {
        switch sensitivity {
        case .friolero:
            return "Sueles necesitar una capa adicional frente a la media."
        case .normal:
            return "Equilibrio estándar respecto a las condiciones registradas."
        case .caluroso:
            return "Prefieres prendas más ligeras o toleras menor abrigo."
        }
    }
}

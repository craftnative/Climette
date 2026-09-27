import SwiftUI
import SwiftData

public struct WardrobeFilterConfig: Equatable, Sendable {
    public var selectedZones: Set<BodyZone> = []
    public var minThermal: Double = 0
    public var minWind: Double = 0
    public var minRain: Double = 0

    public var isDefault: Bool {
        selectedZones.isEmpty && minThermal == 0 && minWind == 0 && minRain == 0
    }

    public mutating func reset() {
        selectedZones.removeAll()
        minThermal = 0
        minWind = 0
        minRain = 0
    }

    public init(
        selectedZones: Set<BodyZone> = [],
        minThermal: Double = 0,
        minWind: Double = 0,
        minRain: Double = 0
    ) {
        self.selectedZones = selectedZones
        self.minThermal = minThermal
        self.minWind = minWind
        self.minRain = minRain
    }
}

struct WardrobeFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filterConfig: WardrobeFilterConfig

    var body: some View {
        NavigationStack {
            Form {
                Section("Zona del cuerpo") {
                    ForEach(BodyZone.allCases, id: \.self) { zone in
                        Toggle(isOn: Binding(
                            get: { filterConfig.selectedZones.contains(zone) },
                            set: { isSelected in
                                if isSelected {
                                    filterConfig.selectedZones.insert(zone)
                                } else {
                                    filterConfig.selectedZones.remove(zone)
                                }
                            }
                        )) {
                            Text(zone.rawValue.capitalized)
                        }
                    }
                }

                Section("Protección mínima") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Térmica", systemImage: "thermometer.medium")
                            Spacer()
                            Text("\(Int(filterConfig.minThermal))/10")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $filterConfig.minThermal, in: 0...10, step: 1)
                            .tint(Color("AccentColor"))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Viento", systemImage: "wind")
                            Spacer()
                            Text("\(Int(filterConfig.minWind))/10")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $filterConfig.minWind, in: 0...10, step: 1)
                            .tint(Color("AccentColor"))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Lluvia", systemImage: "drop.fill")
                            Spacer()
                            Text("\(Int(filterConfig.minRain))/10")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $filterConfig.minRain, in: 0...10, step: 1)
                            .tint(Color("AccentColor"))
                    }
                }

                if !filterConfig.isDefault {
                    Section {
                        Button(role: .destructive) {
                            filterConfig.reset()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Restablecer filtros")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundBase").ignoresSafeArea())
            .navigationTitle("Filtrar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("AccentColor"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

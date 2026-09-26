import SwiftUI

public struct HistoryFilterCriteria: Equatable, Sendable {
    public var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
    public var endDate: Date = .now
    
    public var temperatureRange: ClosedRange<Double> = -10...50
    public var humidityRange: ClosedRange<Double> = 0...100
    public var windSpeedRange: ClosedRange<Double> = 0...120
    
    public var rainOption: RainFilterOption = .all
    
    public init() {}
}

public struct DualRangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    let unit: String
    
    private let thumbSize: CGFloat = 26
    
    public init(
        range: Binding<ClosedRange<Double>>,
        bounds: ClosedRange<Double>,
        step: Double = 1.0,
        unit: String = ""
    ) {
        self._range = range
        self.bounds = bounds
        self.step = step
        self.unit = unit
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(String(format: "%.0f%@", range.lowerBound, unit))
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(Color("AccentColor"))
                Spacer()
                Text(String(format: "%.0f%@", range.upperBound, unit))
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(Color("AccentColor"))
            }
            
            GeometryReader { proxy in
                let availableWidth = max(0, proxy.size.width - thumbSize)
                let totalSpan = bounds.upperBound - bounds.lowerBound
                
                let lowerPercent = CGFloat((range.lowerBound - bounds.lowerBound) / totalSpan)
                let upperPercent = CGFloat((range.upperBound - bounds.lowerBound) / totalSpan)
                
                let lowerOffset = lowerPercent * availableWidth
                let upperOffset = upperPercent * availableWidth
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color("SeparatorBase").opacity(0.4))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(Color("AccentColor"))
                        .frame(width: max(0, upperOffset - lowerOffset), height: 6)
                        .offset(x: lowerOffset + (thumbSize / 2))
                    
                    thumbCircle
                        .offset(x: lowerOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let dragPercent = Double(min(max(0, value.location.x), upperOffset) / availableWidth)
                                    let rawValue = bounds.lowerBound + (dragPercent * totalSpan)
                                    let stepped = (rawValue / step).rounded() * step
                                    let clamped = min(max(stepped, bounds.lowerBound), range.upperBound)
                                    range = clamped...range.upperBound
                                }
                        )
                    
                    thumbCircle
                        .offset(x: upperOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let dragPercent = Double(min(max(lowerOffset, value.location.x), availableWidth) / availableWidth)
                                    let rawValue = bounds.lowerBound + (dragPercent * totalSpan)
                                    let stepped = (rawValue / step).rounded() * step
                                    let clamped = max(min(stepped, bounds.upperBound), range.lowerBound)
                                    range = range.lowerBound...clamped
                                }
                        )
                }
                .frame(maxHeight: .infinity)
            }
            .frame(height: thumbSize)
        }
        .padding(.vertical, 4)
    }
    
    private var thumbCircle: some View {
        Circle()
            .fill(Color("SurfaceElevated"))
            .frame(width: thumbSize, height: thumbSize)
            .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 1)
            .overlay(
                Circle()
                    .stroke(Color("SeparatorBase").opacity(0.6), lineWidth: 0.5)
            )
    }
}

public struct HistoryFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var criteria: HistoryFilterCriteria
    @Binding var isFilterActive: Bool
    
    @State private var draftCriteria: HistoryFilterCriteria
    
    private let now = Date.now
    
    public init(
        criteria: Binding<HistoryFilterCriteria>,
        isFilterActive: Binding<Bool>
    ) {
        self._criteria = criteria
        self._isFilterActive = isFilterActive
        self._draftCriteria = State(initialValue: criteria.wrappedValue)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Rango de fechas") {
                    DatePicker(
                        "Desde",
                        selection: Binding(
                            get: { draftCriteria.startDate },
                            set: { newDate in
                                draftCriteria.startDate = newDate
                                if draftCriteria.startDate > draftCriteria.endDate {
                                    draftCriteria.endDate = newDate
                                }
                            }
                        ),
                        in: ...now,
                        displayedComponents: .date
                    )
                    
                    DatePicker(
                        "Hasta",
                        selection: Binding(
                            get: { draftCriteria.endDate },
                            set: { newDate in
                                draftCriteria.endDate = newDate
                                if draftCriteria.endDate < draftCriteria.startDate {
                                    draftCriteria.startDate = newDate
                                }
                            }
                        ),
                        in: ...now,
                        displayedComponents: .date
                    )
                }
                .listRowBackground(Color("SurfaceElevated"))
                
                Section("Condiciones Climáticas") {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Temperatura", systemImage: "thermometer.medium")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color("TextPrimary"))
                        DualRangeSlider(
                            range: $draftCriteria.temperatureRange,
                            bounds: -20...55,
                            step: 1,
                            unit: "°C"
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Humedad", systemImage: "humidity")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color("TextPrimary"))
                        DualRangeSlider(
                            range: $draftCriteria.humidityRange,
                            bounds: 0...100,
                            step: 1,
                            unit: "%"
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Velocidad del viento", systemImage: "wind")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color("TextPrimary"))
                        DualRangeSlider(
                            range: $draftCriteria.windSpeedRange,
                            bounds: 0...150,
                            step: 5,
                            unit: " km/h"
                        )
                    }
                }
                .listRowBackground(Color("SurfaceElevated"))
                
                Section("Precipitación") {
                    Picker("Lluvia", selection: $draftCriteria.rainOption) {
                        ForEach(RainFilterOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color("SurfaceElevated"))
                
                if isFilterActive {
                    Section {
                        Button(role: .destructive) {
                            draftCriteria = HistoryFilterCriteria()
                            criteria = draftCriteria
                            isFilterActive = false
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Restablecer todos los filtros")
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color("SurfaceElevated"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundBase").ignoresSafeArea())
            .navigationTitle("Filtrar historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar") {
                        criteria = draftCriteria
                        isFilterActive = true
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(Color("AccentColor"))
                }
            }
        }
    }
}

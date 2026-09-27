import SwiftUI

public struct HistoryRecordCardView: View {
    let record: FeedbackRecordEntity
    let isEditable: Bool
    let onSelect: () -> Void
    let onEdit: (() -> Void)?
    
    private enum RecommendationState {
        case correct
        case incorrect
        case adjusted
        case ignored
        case deleted
        
        var label: String {
            switch self {
            case .correct: return "Correcta"
            case .incorrect: return "Incorrecta"
            case .adjusted: return "Incorrecta (Ajustada)"
            case .ignored: return "Ignorada"
            case .deleted: return "Eliminada"
            }
        }
        
        var color: Color {
            switch self {
            case .correct: return .green
            case .incorrect: return .red
            case .adjusted: return .orange
            case .ignored: return .secondary
            case .deleted: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .correct: return "checkmark.seal.fill"
            case .incorrect: return "xmark.circle.fill"
            case .adjusted: return "slider.horizontal.3"
            case .ignored: return "eye.slash"
            case .deleted: return "trash"
            }
        }
    }
    
    private var resolvedState: RecommendationState {
        let baseState = DailyCollectionState(rawValue: record.collectionStateRaw)
        if baseState == .deleted { return .deleted }
        if baseState == .ignored { return .ignored }
        
        let hasAdjustment = record.adjustedGarment != nil ||
                            record.physicalReactionRaw == PhysicalReaction.adjustedClothing.rawValue ||
                            baseState == .adjusted
        
        let isDiscomfort = record.perceptionRaw == ThermalPerception.feltCold.rawValue ||
                           record.perceptionRaw == ThermalPerception.feltHot.rawValue
        
        if hasAdjustment {
            return .adjusted
        } else if isDiscomfort {
            return .incorrect
        } else {
            return .correct
        }
    }
    
    public init(
        record: FeedbackRecordEntity,
        isEditable: Bool,
        onSelect: @escaping () -> Void,
        onEdit: (() -> Void)? = nil
    ) {
        self.record = record
        self.isEditable = isEditable
        self.onSelect = onSelect
        self.onEdit = onEdit
    }
    
    public var body: some View {
        let state = resolvedState
        let weather = record.weatherSnapshot
        let isRain = weather?.precipitationRaw == PrecipitationState.rainy.rawValue
        
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.timestamp.formatted(.dateTime.weekday(.wide)).capitalized)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("TextSecondary"))
                        Text(record.timestamp.formatted(.dateTime.day().month(.wide)))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    Spacer()
                    Image(systemName: weatherIcon(for: weather))
                        .font(.system(size: 32))
                        .symbolRenderingMode(.multicolor)
                }
                
                HStack(alignment: .firstTextBaseline) {
                    Text(String(format: "%.0f°", weather?.temperature ?? 0))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("TextPrimary"))
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "wind")
                                Text(String(format: "%.0f km/h", weather?.windSpeedKmh ?? 0))
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "humidity")
                                Text(weather?.precipitationRaw ?? "Seco")
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "cloud.rain")
                                Text("Lluvia: \(isRain ? "SÍ" : "NO")")
                                    .fontWeight(isRain ? .bold : .regular)
                                    .foregroundStyle(isRain ? Color("AccentColor") : Color("TextSecondary"))
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "cloud.sun")
                                Text(weather?.skyCoverRaw ?? "Despejado")
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
                }
                
                if state == .adjusted {
                    garmentModificationsPreview
                }
                
                Divider()
                    .background(Color("SeparatorBase"))
                
                HStack {
                    statusTag(for: state)
                    Spacer()
                    if isEditable {
                        Button {
                            onEdit?()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Editar")
                                    .font(.caption.weight(.semibold))
                                Image(systemName: "pencil")
                                    .font(.caption)
                            }
                            .foregroundStyle(Color("AccentColor"))
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color("SurfaceElevated"))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(state.color.opacity(state == .correct ? 0.0 : 0.4), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(HistoryCardButtonStyle())
    }

    @ViewBuilder
    private var garmentModificationsPreview: some View {
        let added = record.addedGarments
        let removed = record.removedGarments

        if !added.isEmpty || !removed.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                if !added.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(added, id: \.id) { garment in
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 8, weight: .bold))
                                    Text(garment.canonicalName)
                                }
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.12))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }

                if !removed.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(removed, id: \.id) { garment in
                                HStack(spacing: 4) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 8, weight: .bold))
                                    Text(garment.canonicalName)
                                }
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.12))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func statusTag(for state: RecommendationState) -> some View {
        HStack(spacing: 4) {
            Image(systemName: state.icon)
                .font(.caption2)
            Text(state.label)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(state.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(state.color.opacity(0.12))
        .clipShape(Capsule())
    }
    
    private func weatherIcon(for snapshot: WeatherSnapshotEntity?) -> String {
        guard let snapshot else { return "sun.max.fill" }
        if snapshot.precipitationRaw == PrecipitationState.rainy.rawValue { return "cloud.rain.fill" }
        if snapshot.temperature <= 0.0 { return "snowflake" }
        if snapshot.skyCoverRaw == SkyCover.overcast.rawValue { return "cloud.fill" }
        if snapshot.windSpeedKmh > 25.0 { return "wind" }
        return "sun.max.fill"
    }
}

private struct HistoryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

import SwiftUI

public struct HistoryRecordCardView: View {
    let record: FeedbackRecordEntity
    let isEditable: Bool
    let onSelect: () -> Void
    let onEdit: (() -> Void)?
    
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
        let state = DailyCollectionState(rawValue: record.collectionStateRaw) ?? .correct
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
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(HistoryCardButtonStyle())
    }
    
    private func statusTag(for state: DailyCollectionState) -> some View {
        let (label, color): (String, Color) = switch state {
        case .correct:
            ("Correcta", .green)
        case .adjusted:
            ("Incorrecta / Ajustada", .orange)
        case .ignored:
            ("Ignorada", .secondary)
        case .deleted:
            ("Eliminada", .red)
        }
        
        return Text(label)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
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

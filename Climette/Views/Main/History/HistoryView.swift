import SwiftUI
import SwiftData

public struct HistoryMonthSection: Identifiable {
    public let id: String
    public let monthYearTitle: String
    public let records: [FeedbackRecordEntity]

    public init(id: String, monthYearTitle: String, records: [FeedbackRecordEntity]) {
        self.id = id
        self.monthYearTitle = monthYearTitle
        self.records = records
    }
}

private struct RecordDetailContext: Identifiable {
    var id: PersistentIdentifier { record.persistentModelID }
    let record: FeedbackRecordEntity
    let startInEditMode: Bool
}

public struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FeedbackRecordEntity.timestamp, order: .reverse)
    private var allRecords: [FeedbackRecordEntity]
    
    @State private var selectedRecordContext: RecordDetailContext?
    @State private var isShowingFilterSheet: Bool = false
    
    @State private var isFilterActive: Bool = false
    @State private var filterCriteria = HistoryFilterCriteria()
    
    private let calendar = Calendar.current
    private let now = Date.now
    
    private var editableRecordIDs: Set<PersistentIdentifier> {
        guard let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: calendar.startOfDay(for: now)) else {
            return []
        }
        let recordsWithinThreeDays = allRecords.filter {
            $0.timestamp >= twoDaysAgo && $0.timestamp <= now
        }
        return Set(recordsWithinThreeDays.map(\.persistentModelID))
    }
    
    private func isRecordEditable(_ record: FeedbackRecordEntity) -> Bool {
        editableRecordIDs.contains(record.persistentModelID)
    }
    
    private var filteredAndGroupedSections: [HistoryMonthSection] {
        let validRecords = allRecords.filter { record in
            guard record.timestamp <= now else { return false }
            guard isFilterActive else { return true }
            
            let effectiveStart = min(filterCriteria.startDate, filterCriteria.endDate)
            let effectiveEnd = max(filterCriteria.startDate, filterCriteria.endDate)
            
            let startOfDay = calendar.startOfDay(for: effectiveStart)
            guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: effectiveEnd),
                  record.timestamp >= startOfDay && record.timestamp <= endOfDay else {
                return false
            }
            
            if let weather = record.weatherSnapshot {
                guard filterCriteria.temperatureRange.contains(weather.temperature) else { return false }
                
                if let hum = weather.humidity {
                    guard filterCriteria.humidityRange.contains(hum) else { return false }
                }
                
                guard filterCriteria.windSpeedRange.contains(weather.windSpeedKmh) else { return false }
                
                let isRain = weather.precipitationRaw == PrecipitationState.rainy.rawValue
                switch filterCriteria.rainOption {
                case .all:
                    break
                case .onlyRain:
                    guard isRain else { return false }
                case .noRain:
                    guard !isRain else { return false }
                }
            }
            
            return true
        }
        
        let grouped = Dictionary(grouping: validRecords) { record -> DateComponents in
            calendar.dateComponents([.year, .month], from: record.timestamp)
        }
        
        let sortedKeys = grouped.keys.sorted { k1, k2 in
            let date1 = calendar.date(from: k1) ?? .distantPast
            let date2 = calendar.date(from: k2) ?? .distantPast
            return date1 > date2
        }
        
        return sortedKeys.compactMap { key in
            guard let recordsInGroup = grouped[key],
                  let sectionDate = calendar.date(from: key) else { return nil }
            
            let title = sectionDate.formatted(.dateTime.year().month(.wide)).capitalized
            let sectionID = "\(key.year ?? 0)-\(key.month ?? 0)"
            let sortedDayRecords = recordsInGroup.sorted { $0.timestamp > $1.timestamp }
            
            return HistoryMonthSection(
                id: sectionID,
                monthYearTitle: title,
                records: sortedDayRecords
            )
        }
    }
    
    public var body: some View {
        Group {
            if filteredAndGroupedSections.isEmpty {
                emptyStateView
            } else {
                contentScrollView
            }
        }
        .background(Color("BackgroundBase").ignoresSafeArea())
        .navigationTitle(Text("Historial"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingFilterSheet = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color("AccentColor"))
                        
                        if isFilterActive {
                            Circle()
                                .fill(Color("AccentColor"))
                                .frame(width: 8, height: 8)
                                .offset(x: 2, y: -2)
                        }
                    }
                }
                .accessibilityLabel("Filtros avanzados")
            }
        }
        .sheet(item: $selectedRecordContext) { context in
            FeedbackEditSheet(
                recordEntity: context.record,
                isEligibleForEdit: isRecordEditable(context.record),
                initialEditMode: context.startInEditMode
            )
        }
        .sheet(isPresented: $isShowingFilterSheet) {
            HistoryFilterSheet(
                criteria: $filterCriteria,
                isFilterActive: $isFilterActive
            )
        }
    }
    
    private var contentScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                if isFilterActive {
                    activeFilterBanner
                        .padding(.horizontal)
                        .padding(.top, 4)
                }
                
                ForEach(filteredAndGroupedSections) { section in
                    monthSection(section)
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    private func monthSection(_ section: HistoryMonthSection) -> some View {
        Section {
            LazyVStack(spacing: 14) {
                ForEach(section.records) { record in
                    recordCard(for: record)
                }
            }
            .padding(.horizontal)
        } header: {
            stickyMonthHeader(title: section.monthYearTitle)
        }
    }
    
    private func recordCard(for record: FeedbackRecordEntity) -> some View {
        let editable = isRecordEditable(record)
        return HistoryRecordCardView(
            record: record,
            isEditable: editable,
            onSelect: {
                selectedRecordContext = RecordDetailContext(
                    record: record,
                    startInEditMode: false
                )
            },
            onEdit: {
                guard editable else { return }
                selectedRecordContext = RecordDetailContext(
                    record: record,
                    startInEditMode: true
                )
            }
        )
    }
    
    private var activeFilterBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundStyle(Color("AccentColor"))
            
            Text("Filtros aplicados")
                .font(.caption.weight(.medium))
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut) {
                    isFilterActive = false
                    filterCriteria = HistoryFilterCriteria()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color("SurfaceElevated"))
        .clipShape(Capsule())
    }
    
    private func stickyMonthHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("TextPrimary"))
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color("BackgroundBase").opacity(0.95))
    }
    
    private var emptyStateView: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 64))
                    .foregroundStyle(Color("AccentColor"))
                    .accessibilityHidden(true)
                
                Text(isFilterActive ? "Sin resultados" : "history_empty_title")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color("TextPrimary"))
                
                Text(isFilterActive ? "No hay registros que coincidan con los filtros seleccionados." : "history_empty_description")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("TextSecondary"))
                    .padding(.horizontal, 32)
                
                if isFilterActive {
                    Button("Restablecer filtros") {
                        withAnimation {
                            isFilterActive = false
                            filterCriteria = HistoryFilterCriteria()
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AccentColor"))
                    .padding(.top, 12)
                }
            }
            .padding(.top, 48)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
        }
    }
}

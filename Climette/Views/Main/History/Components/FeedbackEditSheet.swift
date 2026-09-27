import SwiftUI
import SwiftData
import AppIntents
import FoundationModels
@preconcurrency import Speech
import AVFoundation
import os

private let logger = Logger(subsystem: "craftnative.studio.Climette", category: "FeedbackEditSheet")

private struct GarmentReplacementContext: Identifiable {
    var id: UUID { garment.id }
    let garment: ClothingItemEntity
}

private var isAppleIntelligenceReady: Bool {
    switch SystemLanguageModel.default.availability {
    case .available:
        return true
    case .unavailable(.appleIntelligenceNotEnabled), .unavailable(.modelNotReady):
        return false
    case .unavailable(.deviceNotEligible):
        return false
    @unknown default:
        return false
    }
}

private enum GarmentVisualStatus {
    case kept
    case added
    case removed

    var badgeTitle: String? {
        switch self {
        case .kept: return nil
        case .added: return "Añadida"
        case .removed: return "Retirada"
        }
    }

    var badgeIcon: String? {
        switch self {
        case .kept: return nil
        case .added: return "plus"
        case .removed: return "minus"
        }
    }

    var color: Color {
        switch self {
        case .kept: return Color("AccentColor")
        case .added: return .green
        case .removed: return .red
        }
    }
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
    
    @State private var feedbackDate: Date = .now
    @State private var evaluationPeriod: DayEvaluationPeriod = .allDay
    
    @State private var currentGarments: [ClothingItemEntity] = []
    @State private var originalRecommendedGarments: [ClothingItemEntity] = []
    @State private var removedGarments: [ClothingItemEntity] = []
    
    @State private var isShowingAddSheet: Bool = false
    @State private var garmentToReplaceContext: GarmentReplacementContext?
    
    // Estados de voz y Apple Intelligence
    @State private var isRecording: Bool = false
    @State private var isProcessingAI: Bool = false
    @State private var transcribedText: String = ""
    @State private var voiceErrorMessage: String?
    
    @State private var audioEngine: AVAudioEngine?
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    
    init(recordEntity: FeedbackRecordEntity, isEligibleForEdit: Bool, initialEditMode: Bool = false) {
        self.recordEntity = recordEntity
        self.isEligibleForEdit = isEligibleForEdit
        self.initialEditMode = isEligibleForEdit && initialEditMode
        self._isEditing = State(initialValue: isEligibleForEdit && initialEditMode)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if isEditing {
                    if isAppleIntelligenceReady {
                        appleIntelligenceSection
                    }
                }
                
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
                    removedGarments.removeAll(where: { $0.id == selected.id })
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
                        if !removedGarments.contains(where: { $0.id == target.id }) {
                            removedGarments.append(target)
                        }
                    }
                }
            }
            .onAppear {
                loadRecordData()
            }
            .onDisappear {
                stopAudioCapture()
            }
        }
    }
    
    @ViewBuilder
    private var appleIntelligenceSection: some View {
        Section {
            Button {
                Task {
                    if isRecording {
                        logger.debug("Botón presionado: Detener grabación")
                        await stopRecordingAndProcess()
                    } else {
                        logger.debug("Botón presionado: Iniciar grabación")
                        await startRecording()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if isProcessingAI {
                        ProgressView().tint(.white)
                        Text("Analizando...")
                    } else if isRecording {
                        Image(systemName: "stop.circle.fill")
                        Text("Detener y procesar")
                    } else {
                        Image(systemName: "apple.intelligence")
                        Text("Describir con voz")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(isRecording ? .red : Color.purple)
            .disabled(isProcessingAI)
            
            if !transcribedText.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transcripción:")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("TextSecondary"))
                    Text(transcribedText)
                        .font(.caption)
                        .foregroundStyle(Color("TextPrimary"))
                }
                .padding(.vertical, 2)
            }
            
            if let voiceErrorMessage {
                Text(voiceErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Apple Intelligence")
        } footer: {
            Text("Describe verbalmente tu atuendo y sensación térmica para calibrar automáticamente las opciones.")
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
        }
        .listRowBackground(Color("SurfaceElevated"))
    }
    
    @MainActor
    private func requestPermissions() async -> Bool {
        logger.debug("Iniciando solicitud de permisos de micrófono/voz en Vista...")
        let micAllowed = await AVAudioApplication.requestRecordPermission()
        logger.debug("Resultado permiso micrófono: \(micAllowed)")
        guard micAllowed else {
            voiceErrorMessage = "Acceso al micrófono denegado. Permítelo en los Ajustes del sistema."
            return false
        }
        
        let speechStatus = await Self.requestSpeechRecognizerAuthorization()
        logger.debug("Resultado permiso SFSpeechRecognizer: \(String(describing: speechStatus.rawValue))")
        guard speechStatus == .authorized else {
            voiceErrorMessage = "Acceso al reconocimiento de voz denegado. Permítelo en Ajustes."
            return false
        }
        
        voiceErrorMessage = nil
        return true
    }
    
    nonisolated private static func requestSpeechRecognizerAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }
    
    nonisolated private static func configureAndActivateAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    nonisolated private static func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    @MainActor
    private func startRecording() async {
        logger.debug("startRecording() invocado en FeedbackEditSheet")
        guard await requestPermissions() else { return }
        
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES")) ?? SFSpeechRecognizer()
        guard let recognizer, recognizer.isAvailable else {
            logger.error("SFSpeechRecognizer no disponible para es-ES")
            voiceErrorMessage = "El reconocedor de voz no está disponible en este momento."
            return
        }
        
        stopAudioCapture()
        
        do {
            logger.debug("Configurando AVAudioSession en hilo secundario...")
            try await Task.detached(priority: .userInitiated) {
                try Self.configureAndActivateAudioSession()
            }.value
            
            let engine = AVAudioEngine()
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            
            self.audioEngine = engine
            self.recognitionRequest = request
            self.transcribedText = ""
            
            let inputNode = engine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            
            logger.debug("Instalando tap en AVAudioEngine (Vista)...")
            
            // CORRECCIÓN VITAL PARA SWIFT 6: El bloque del tap se ejecuta en el hilo secundario
            // de audio en tiempo real de AVAudioEngine. Marcarlo como @Sendable evita que herede
            // el aislamiento de @MainActor y colapse (_dispatch_assert_queue_fail).
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { @Sendable [weak request] buffer, _ in
                request?.append(buffer)
            }
            
            engine.prepare()
            try engine.start()
            logger.debug("AVAudioEngine iniciado correctamente (Vista).")
            
            self.isRecording = true
            
            self.recognitionTask = recognizer.recognitionTask(with: request) { @Sendable result, error in
                let partialTranscript = result?.bestTranscription.formattedString
                let localizedError = error?.localizedDescription
                
                Task { @MainActor in
                    if let partialTranscript {
                        self.transcribedText = partialTranscript
                    }
                    if let localizedError {
                        logger.error("Error asíncrono en recognitionTask: \(localizedError)")
                        self.stopAudioCapture()
                        self.isRecording = false
                    }
                }
            }
        } catch {
            logger.error("Fallo al iniciar captura de audio: \(error.localizedDescription)")
            voiceErrorMessage = "Error al iniciar captura de audio: \(error.localizedDescription)"
            stopAudioCapture()
            isRecording = false
        }
    }
    
    @MainActor
    private func stopRecordingAndProcess() async {
        logger.debug("Deteniendo grabación e iniciando procesamiento AI...")
        stopAudioCapture()
        isRecording = false
        
        let cleanedText = transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedText.isEmpty else {
            logger.warning("El texto transcrito está vacío, abortando extracción.")
            voiceErrorMessage = "No se detectó ninguna instrucción hablada."
            return
        }
        
        await extractFeedbackFromAI(cleanedText)
    }
    
    @MainActor
    private func stopAudioCapture() {
        logger.debug("stopAudioCapture() invocado")
        if let engine = audioEngine, engine.isRunning {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
            logger.debug("AVAudioEngine detenido y tap removido")
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        
        Task.detached(priority: .utility) {
            Self.deactivateAudioSession()
        }
    }
    
    @MainActor
    private func extractFeedbackFromAI(_ promptText: String) async {
        logger.debug("Iniciando LanguageModelSession con texto: \(promptText)")
        isProcessingAI = true
        voiceErrorMessage = nil
        defer { isProcessingAI = false }
        
        do {
            let session = LanguageModelSession(
                instructions: "Eres un asistente de moda y clima. Extrae los detalles del atuendo descrito y la sensación térmica del usuario según el esquema proporcionado."
            )
            
            let response = try await session.respond(
                to: promptText,
                generating: VoiceFeedbackExtractionDTO.self
            )
            
            logger.debug("Respuesta AI recibida exitosamente.")
            let extractedDTO = response.content
            
            let editState = extractedDTO.mapToEditState(
                catalog: allCatalogGarments,
                currentWornGarments: currentGarments
            )
            
            withAnimation {
                self.evaluationPeriod = editState.evaluationPeriod
                self.isIndoorDistortion = editState.isIndoorDistortion
                self.currentGarments = editState.wornGarments
                
                if editState.perception == .perfect && editState.physicalReaction != .adjustedClothing {
                    self.didWork = true
                } else {
                    self.didWork = false
                    self.failureReason = editState.perception == .perfect ? .feltCold : editState.perception
                }
            }
        } catch {
            logger.error("Error en extractFeedbackFromAI: \(error.localizedDescription)")
            voiceErrorMessage = "Error al analizar texto con Apple Intelligence: \(error.localizedDescription)"
        }
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section {
            if isEditing {
                DatePicker("Fecha y hora", selection: $feedbackDate, in: ...Date.now)
                
                Picker("Periodo evaluado", selection: $evaluationPeriod) {
                    ForEach(DayEvaluationPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.menu)
            } else {
                detailRow(
                    icon: "calendar",
                    title: "Fecha",
                    value: recordEntity.timestamp.formatted(.dateTime.day().month(.wide).year())
                )
                
                detailRow(
                    icon: "clock",
                    title: "Periodo",
                    value: evaluationPeriod.rawValue
                )
            }
            
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
    
    private var evaluationResultDetails: (title: String, icon: String, color: Color) {
        if didWork {
            return ("Correcto", "checkmark.circle.fill", .green)
        } else if recordEntity.recommendationState == .adjusted {
            return ("Incorrecto pero ajustado", "slider.horizontal.3", .orange)
        } else {
            return ("Incorrecto", "xmark.circle.fill", .red)
        }
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
                let result = evaluationResultDetails
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(result.color.opacity(0.12))
                            .frame(width: 32, height: 32)
                        Image(systemName: result.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(result.color)
                    }
                    
                    Text("Resultado")
                        .foregroundStyle(Color("TextSecondary"))
                    
                    Spacer()
                    
                    Text(result.title)
                        .foregroundStyle(result.color)
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
            if isEditing {
                editingGarmentsContent
            } else {
                detailedGarmentsContent
            }
        } header: {
            Text("Ropa vestida")
        } footer: {
            if isEditing {
                Text("Desliza hacia la izquierda sobre una prenda para retirarla o pulsa Cambiar para sustituirla.")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            } else if recordEntity.recommendationState == .adjusted {
                Text("Verde: prendas añadidas durante el día. Rojo: prendas recomendadas que se retiraron.")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            }
        }
        .listRowBackground(Color("SurfaceElevated"))
    }
    
    @ViewBuilder
    private var editingGarmentsContent: some View {
        if currentGarments.isEmpty {
            Text("No hay prendas registradas para este atuendo.")
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
        } else {
            ForEach(currentGarments, id: \.id) { garment in
                let isAdded = !originalRecommendedGarments.contains(where: { $0.id == garment.id })
                HStack(spacing: 12) {
                    garmentIconView(zone: garment.bodyZoneRaw, status: isAdded ? .added : .kept)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(garment.canonicalName)
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color("TextPrimary"))
                        
                        Text(garment.bodyZoneRaw.capitalized)
                            .font(.caption2)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    
                    Spacer()
                    
                    if isAdded {
                        Button {
                            withAnimation {
                                currentGarments.removeAll(where: { $0.id == garment.id })
                                removedGarments.removeAll(where: { $0.id == garment.id })
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                Text("Quitar")
                            }
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    Button {
                        garmentToReplaceContext = GarmentReplacementContext(garment: garment)
                    } label: {
                        Text("Cambiar")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AccentColor"))
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 2)
            }
            .onDelete(perform: removeGarments)
        }
        
        HStack {
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
            
            Spacer()
            
            if currentGarments.map(\.id) != originalRecommendedGarments.map(\.id) {
                Button("Restablecer original") {
                    withAnimation {
                        currentGarments = originalRecommendedGarments
                        removedGarments.removeAll()
                    }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var detailedGarmentsContent: some View {
        let isAdjusted = recordEntity.recommendationState == .adjusted
        let kept = recordEntity.keptGarments
        let added = recordEntity.addedGarments
        let removed = recordEntity.removedGarments
        
        if kept.isEmpty && added.isEmpty && removed.isEmpty {
            Text("No hay prendas registradas para este atuendo.")
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
        } else if !isAdjusted {
            ForEach(currentGarments, id: \.id) { garment in
                garmentRowView(garment: garment, status: .kept)
            }
        } else {
            ForEach(kept, id: \.id) { garment in
                garmentRowView(garment: garment, status: .kept)
            }
            ForEach(added, id: \.id) { garment in
                garmentRowView(garment: garment, status: .added)
            }
            ForEach(removed, id: \.id) { garment in
                garmentRowView(garment: garment, status: .removed)
            }
        }
    }
    
    private func garmentRowView(garment: ClothingItemEntity, status: GarmentVisualStatus) -> some View {
        HStack(spacing: 12) {
            garmentIconView(zone: garment.bodyZoneRaw, status: status)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(garment.canonicalName)
                    .font(.body.weight(.medium))
                    .foregroundStyle(status == .removed ? Color("TextSecondary") : Color("TextPrimary"))
                    .strikethrough(status == .removed, color: .red)
                
                Text(garment.bodyZoneRaw.capitalized)
                    .font(.caption2)
                    .foregroundStyle(Color("TextSecondary"))
            }
            
            Spacer()
            
            if let title = status.badgeTitle, let icon = status.badgeIcon {
                statusBadge(title: title, icon: icon, color: status.color)
            }
        }
        .padding(.vertical, 2)
    }
    
    private func garmentIconView(zone: String, status: GarmentVisualStatus) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(status.color.opacity(0.12))
                .frame(width: 36, height: 36)
            
            Image(systemName: iconForGarmentZone(zone))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(status.color)
        }
    }
    
    private func statusBadge(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
            Text(title)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
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
        for index in offsets {
            let removedItem = currentGarments[index]
            let wasOriginallyRecommended = originalRecommendedGarments.contains(where: { $0.id == removedItem.id })
            
            if wasOriginallyRecommended && !removedGarments.contains(where: { $0.id == removedItem.id }) {
                removedGarments.append(removedItem)
            }
        }
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
        
        let base = recordEntity.recommendedGarments ?? []
        originalRecommendedGarments = base.isEmpty ? (recordEntity.wornGarments ?? []) : base
        removedGarments = recordEntity.removedGarments
        feedbackDate = recordEntity.timestamp
        evaluationPeriod = DayEvaluationPeriod(rawValue: recordEntity.evaluatedPeriodRaw ?? "") ?? .allDay
    }
    
    @MainActor
    private func saveChanges() {
        recordEntity.timestamp = feedbackDate
        recordEntity.evaluatedPeriodRaw = evaluationPeriod.rawValue
        
        if recordEntity.recommendedGarments == nil || recordEntity.recommendedGarments?.isEmpty == true {
            recordEntity.recommendedGarments = originalRecommendedGarments
        }
        
        let baseRecommended = recordEntity.recommendedGarments ?? []
        let baseIDs = Set(baseRecommended.map(\.id))
        let currentIDs = Set(currentGarments.map(\.id))
        let hasOutfitChanged = baseIDs != currentIDs
        
        recordEntity.wornGarments = currentGarments
        
        if didWork {
            recordEntity.collectionStateRaw = DailyCollectionState.correct.rawValue
            recordEntity.perceptionRaw = ThermalPerception.perfect.rawValue
            recordEntity.isIndoorDistortion = false
            recordEntity.physicalReactionRaw = nil
            recordEntity.adjustedGarment = nil
            recordEntity.postAdjustmentStateRaw = nil
        } else {
            recordEntity.perceptionRaw = failureReason.rawValue
            recordEntity.isIndoorDistortion = isIndoorDistortion
            
            if hasOutfitChanged {
                recordEntity.collectionStateRaw = DailyCollectionState.adjusted.rawValue
                recordEntity.physicalReactionRaw = PhysicalReaction.adjustedClothing.rawValue
                
                let newlyAdded = currentGarments.filter { !baseIDs.contains($0.id) }
                let newlyRemoved = baseRecommended.filter { !currentIDs.contains($0.id) }
                
                recordEntity.adjustedGarment = newlyAdded.first ?? newlyRemoved.first
                recordEntity.postAdjustmentStateRaw = PostAdjustmentState.stabilized.rawValue
            } else {
                recordEntity.collectionStateRaw = DailyCollectionState.incorrect.rawValue
                recordEntity.physicalReactionRaw = PhysicalReaction.enduredAsIs.rawValue
                recordEntity.adjustedGarment = nil
                recordEntity.postAdjustmentStateRaw = nil
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

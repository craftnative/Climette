import Foundation
import Speech
import AVFoundation
import Observation
import os

@Observable
@MainActor
public final class SpeechService: NSObject, SpeechServiceProtocol, SFSpeechRecognizerDelegate {
    public private(set) var isRecording: Bool = false
    public private(set) var currentTranscript: String = ""

    @ObservationIgnored private var speechRecognizer: SFSpeechRecognizer?
    @ObservationIgnored private var audioEngine: AVAudioEngine?
    @ObservationIgnored private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @ObservationIgnored private var recognitionTask: SFSpeechRecognitionTask?
    
    @ObservationIgnored private let logger = Logger(subsystem: "craftnative.studio.Climette", category: "SpeechService")

    public override init() {
        super.init()
    }

    public var authorizationStatus: SpeechPermissionStatus {
        let micStatus = AVAudioApplication.shared.recordPermission
        let speechStatus = SFSpeechRecognizer.authorizationStatus()

        if micStatus == .denied || speechStatus == .denied { return .denied }
        if speechStatus == .restricted { return .restricted }
        if micStatus == .granted && speechStatus == .authorized { return .authorized }
        return .notDetermined
    }

    public func requestPermissions() async -> Bool {
        logger.debug("Solicitando permisos de micrófono y reconocimiento de voz...")
        let micGranted = await AVAudioApplication.requestRecordPermission()
        logger.debug("Permiso de micrófono concedido: \(micGranted)")
        guard micGranted else { return false }

        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        logger.debug("Estado de permiso de voz: \(String(describing: speechStatus.rawValue))")
        return speechStatus == .authorized
    }

    public func startRecording(locale: Locale = Locale(identifier: "es-ES")) async throws {
        logger.debug("Iniciando startRecording()...")
        guard await requestPermissions() else {
            logger.error("Permisos denegados al intentar grabar.")
            if AVAudioApplication.shared.recordPermission != .granted {
                throw SpeechServiceError.microphonePermissionDenied
            } else {
                throw SpeechServiceError.speechRecognitionPermissionDenied
            }
        }

        let recognizer = SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer()
        guard let recognizer, recognizer.isAvailable else {
            logger.error("Reconocedor de voz no disponible.")
            throw SpeechServiceError.recognizerUnavailable
        }

        cleanupAudio()

        self.speechRecognizer = recognizer
        recognizer.delegate = self

        do {
            logger.debug("Configurando AVAudioSession...")
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("Fallo al configurar AVAudioSession: \(error.localizedDescription)")
            throw SpeechServiceError.audioSessionConfigurationFailed(error.localizedDescription)
        }

        let engine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        self.audioEngine = engine
        self.recognitionRequest = request
        self.currentTranscript = ""

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        logger.debug("Instalando tap en inputNode...")
        
        // CORRECCIÓN: Capturar la variable local 'request' en lugar de 'self'
        // Evita el acceso cruzado al @MainActor desde el hilo secundario de AVAudioEngine
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak request] buffer, _ in
            request?.append(buffer)
        }

        do {
            engine.prepare()
            try engine.start()
            logger.debug("AVAudioEngine iniciado correctamente.")
        } catch {
            logger.error("Fallo al iniciar AVAudioEngine: \(error.localizedDescription)")
            cleanupAudio()
            throw SpeechServiceError.engineFailure(error.localizedDescription)
        }

        self.isRecording = true

        self.recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let result {
                    self.currentTranscript = result.bestTranscription.formattedString
                    self.logger.debug("Transcripción parcial actualizada: \(self.currentTranscript)")
                }
                if let error = error {
                    self.logger.error("Error en recognitionTask: \(error.localizedDescription)")
                    self.cleanupAudio()
                    self.isRecording = false
                }
            }
        }
    }

    public func stopRecording() async throws -> String {
        logger.debug("Deteniendo grabación...")
        guard isRecording else {
            let fallback = currentTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
            if fallback.isEmpty {
                logger.warning("No hay transcripción disponible al detener.")
                throw SpeechServiceError.noTranscriptionAvailable
            }
            return fallback
        }

        cleanupAudio()
        isRecording = false

        let trimmed = currentTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            logger.warning("Transcripción vacía tras limpieza.")
            throw SpeechServiceError.noTranscriptionAvailable
        }
        logger.debug("Grabación detenida con transcripción final: \(trimmed)")
        return trimmed
    }

    public func cancelRecording() {
        logger.debug("Cancelando grabación forzosamente...")
        cleanupAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false
        currentTranscript = ""
    }

    private func cleanupAudio() {
        logger.debug("Ejecutando cleanupAudio()...")
        if let engine = audioEngine, engine.isRunning {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        audioEngine = nil
        recognitionRequest = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    nonisolated public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        let logger = Logger(subsystem: "craftnative.studio.Climette", category: "SpeechService")
        logger.debug("Disponibilidad de SFSpeechRecognizer cambió a: \(available)")
        if !available {
            Task { @MainActor [weak self] in
                self?.cancelRecording()
            }
        }
    }
}

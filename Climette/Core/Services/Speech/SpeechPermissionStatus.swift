import Foundation

public enum SpeechPermissionStatus: Sendable, Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
}

public enum SpeechServiceError: Error, Sendable, LocalizedError {
    case microphonePermissionDenied
    case speechRecognitionPermissionDenied
    case recognizerUnavailable
    case audioSessionConfigurationFailed(String)
    case engineFailure(String)
    case noTranscriptionAvailable

    public var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "El acceso al micrófono ha sido denegado o no está autorizado."
        case .speechRecognitionPermissionDenied:
            return "El servicio de reconocimiento de voz no cuenta con autorización."
        case .recognizerUnavailable:
            return "El reconocedor de voz no está disponible para el idioma seleccionado o el dispositivo actual."
        case .audioSessionConfigurationFailed(let reason):
            return "Error al configurar la sesión de audio: \(reason)"
        case .engineFailure(let reason):
            return "Fallo en el motor de captura de audio: \(reason)"
        case .noTranscriptionAvailable:
            return "No se ha detectado ninguna locución de voz para procesar."
        }
    }
}

@MainActor
public protocol SpeechServiceProtocol: Sendable {
    var isRecording: Bool { get }
    var currentTranscript: String { get }
    var authorizationStatus: SpeechPermissionStatus { get }
    
    func requestPermissions() async -> Bool
    func startRecording(locale: Locale) async throws
    func stopRecording() async throws -> String
    func cancelRecording()
}

public extension SpeechServiceProtocol {
    func startRecording() async throws {
        try await startRecording(locale: Locale(identifier: "es-ES"))
    }
}

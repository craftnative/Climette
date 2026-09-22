import Foundation

public enum ClothingLayer: String, Codable, CaseIterable, Sendable {
    case base = "Capa Base"
    case mid = "Capa Intermedia"
    case outer = "Capa Exterior"
}

public enum SystemOntology: String, Codable, CaseIterable, Sendable {
    case breathableBase = "base_transpirable"
    case thermalBase = "base_termica"
    case lightMid = "capa_intermedia_ligera"
    case heavyMid = "capa_intermedia_gruesa"
    case windbreakerOuter = "capa_exterior_cortavientos"
    case insulatedOuter = "capa_exterior_aislante"
    case rainShellOuter = "capa_exterior_impermeable"
}

public struct Garment: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public var layer: ClothingLayer
    public var ontology: SystemOntology
    public var userNickname: String?
    public var functionalDescriptor: String

    public var resolvedDisplayName: String {
        if let nickname = userNickname, !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nickname
        }
        return functionalDescriptor
    }

    public init(
        id: UUID = UUID(),
        layer: ClothingLayer,
        ontology: SystemOntology,
        userNickname: String? = nil,
        functionalDescriptor: String
    ) {
        self.id = id
        self.layer = layer
        self.ontology = ontology
        self.userNickname = userNickname
        self.functionalDescriptor = functionalDescriptor
    }
}

public struct Outfit: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public var baseLayer: Garment
    public var midLayer: Garment?
    public var outerLayer: Garment?

    public var allGarments: [Garment] {
        [baseLayer, midLayer, outerLayer].compactMap { $0 }
    }

    public var summaryDescription: String {
        allGarments.map { "[\($0.resolvedDisplayName)]" }.joined(separator: " + ")
    }

    public init(
        id: UUID = UUID(),
        baseLayer: Garment,
        midLayer: Garment? = nil,
        outerLayer: Garment? = nil
    ) {
        self.id = id
        self.baseLayer = baseLayer
        self.midLayer = midLayer
        self.outerLayer = outerLayer
    }
}

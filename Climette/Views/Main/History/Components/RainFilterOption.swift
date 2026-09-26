import Foundation

public enum RainFilterOption: String, CaseIterable, Identifiable, Sendable, Equatable {
    case all = "Todos"
    case onlyRain = "Con lluvia"
    case noRain = "Sin lluvia"
    
    public var id: String { rawValue }
}

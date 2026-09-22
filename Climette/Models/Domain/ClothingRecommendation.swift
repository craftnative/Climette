import Foundation

public enum RecommendationPriority: Int, Codable, Comparable, Sendable {
    case priority1ValidatedSuccess = 1
    case priority2Warning = 2
    case priority3ColdStart = 3

    public static func < (lhs: RecommendationPriority, rhs: RecommendationPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public struct ClothingRecommendation: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let priority: RecommendationPriority
    public let outfit: Outfit
    public let headline: String
    public let formattedMessage: String
    public let correctiveWarning: String?
    public let referenceDate: Date?
    public let generatedAt: Date

    public init(
        id: UUID = UUID(),
        priority: RecommendationPriority,
        outfit: Outfit,
        headline: String,
        formattedMessage: String,
        correctiveWarning: String? = nil,
        referenceDate: Date? = nil,
        generatedAt: Date = .now
    ) {
        self.id = id
        self.priority = priority
        self.outfit = outfit
        self.headline = headline
        self.formattedMessage = formattedMessage
        self.correctiveWarning = correctiveWarning
        self.referenceDate = referenceDate
        self.generatedAt = generatedAt
    }
}

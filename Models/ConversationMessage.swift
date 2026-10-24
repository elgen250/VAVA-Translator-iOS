import Foundation

/// Represents a message turn in live two-way conversational translation.
public struct ConversationMessage: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let speaker: SpeakerSide
    public let originalText: String
    public let translatedText: String
    public let sourceLanguage: SupportedLanguage
    public let targetLanguage: SupportedLanguage
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        speaker: SpeakerSide,
        originalText: String,
        translatedText: String,
        sourceLanguage: SupportedLanguage,
        targetLanguage: SupportedLanguage,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.speaker = speaker
        self.originalText = originalText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.timestamp = timestamp
    }
}

/// Identifies which participant spoke in a dual-language conversation.
public enum SpeakerSide: String, CaseIterable, Codable, Sendable {
    case primary     // First speaker (e.g. Arabic user)
    case secondary   // Second speaker (e.g. English guest)

    public var title: String {
        switch self {
        case .primary: return "المتحدث الأول"
        case .secondary: return "المتحدث الثاني"
        }
    }
}

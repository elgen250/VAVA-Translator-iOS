import Foundation
import SwiftData

/// SwiftData persistent entity representing a recorded translation.
/// Shared across the main app, keyboard extension, and widget via App Group.
@Model
public final class TranslationHistoryItem {
    @Attribute(.unique)
    public var id: UUID
    public var sourceText: String
    public var translatedText: String
    public var sourceLanguageCode: String
    public var targetLanguageCode: String
    public var timestamp: Date
    public var category: String    // "text", "talk", "camera"
    public var isFavorite: Bool

    public init(
        id: UUID = UUID(),
        sourceText: String,
        translatedText: String,
        sourceLanguageCode: String,
        targetLanguageCode: String,
        timestamp: Date = Date(),
        category: String = "text",
        isFavorite: Bool = false
    ) {
        self.id = id
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLanguageCode = sourceLanguageCode
        self.targetLanguageCode = targetLanguageCode
        self.timestamp = timestamp
        self.category = category
        self.isFavorite = isFavorite
    }

    /// Computed property to resolve source language struct
    public var sourceLanguage: SupportedLanguage {
        SupportedLanguage.from(code: sourceLanguageCode)
    }

    /// Computed property to resolve target language struct
    public var targetLanguage: SupportedLanguage {
        SupportedLanguage.from(code: targetLanguageCode)
    }
}

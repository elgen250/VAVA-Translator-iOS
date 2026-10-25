import Foundation
import SwiftData

/// SwiftData persistent entity for categorized vocabulary and phrases.
/// Shared with VAVAWidget for daily interactive home screen learning.
@Model
public final class PhraseItem {
    @Attribute(.unique)
    public var id: String             // e.g. "phrase_greeting_01"
    public var category: String       // "casual", "travel", "academic"
    public var sourceText: String
    public var sourceLanguageCode: String
    public var translatedText: String
    public var targetLanguageCode: String
    public var phoneticTranscription: String?
    public var isFavorite: Bool
    public var masteryLevel: Int      // 0 to 5 stars

    public init(
        id: String = UUID().uuidString,
        category: String = "casual",
        sourceText: String,
        sourceLanguageCode: String = "ar",
        translatedText: String,
        targetLanguageCode: String = "en",
        phoneticTranscription: String? = nil,
        isFavorite: Bool = false,
        masteryLevel: Int = 0
    ) {
        self.id = id
        self.category = category
        self.sourceText = sourceText
        self.sourceLanguageCode = sourceLanguageCode
        self.translatedText = translatedText
        self.targetLanguageCode = targetLanguageCode
        self.phoneticTranscription = phoneticTranscription
        self.isFavorite = isFavorite
        self.masteryLevel = masteryLevel
    }

    public var sourceLanguage: SupportedLanguage {
        SupportedLanguage.from(code: sourceLanguageCode)
    }

    public var targetLanguage: SupportedLanguage {
        SupportedLanguage.from(code: targetLanguageCode)
    }
}

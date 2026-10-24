import Foundation
import Translation
import NaturalLanguage
import Observation

/// Core on-device translation service leveraging Apple Translation.framework (iOS 18+)
/// and NaturalLanguage for real-time offline language identification.
@Observable
public final class TranslationService: @unchecked Sendable {
    public static let shared = TranslationService()

    /// Current translation execution status
    public var isTranslating: Bool = false
    public var lastError: String? = nil
    public var detectedLanguage: SupportedLanguage? = nil

    private let languageRecognizer = NLLanguageRecognizer()

    public init() {}

    /// Detects language from input text using Apple NaturalLanguage framework.
    public func detectLanguage(for text: String) -> SupportedLanguage? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            detectedLanguage = nil
            return nil
        }
        languageRecognizer.reset()
        languageRecognizer.processString(text)
        
        if let dominant = languageRecognizer.dominantLanguage {
            let code = dominant.rawValue
            // Match with supported language list
            if let matched = SupportedLanguage.allLanguages.first(where: { 
                $0.code == code || code.starts(with: $0.code) || $0.code.starts(with: code)
            }) {
                detectedLanguage = matched
                return matched
            }
        }
        detectedLanguage = nil
        return nil
    }

    /// Checks whether the language pair is installed offline or supported for download.
    public func checkAvailability(
        from source: SupportedLanguage,
        to target: SupportedLanguage
    ) async -> LanguageAvailability.Status {
        guard let sourceLocale = source.localeLanguage,
              let targetLocale = target.localeLanguage else {
            return .unsupported
        }

        let availability = LanguageAvailability()
        let status = await availability.status(from: sourceLocale, to: targetLocale)
        return status
    }

    /// Translates text using an active TranslationSession supplied by SwiftUI .translationTask.
    @MainActor
    public func translate(
        text: String,
        using session: TranslationSession
    ) async throws -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ""
        }
        
        isTranslating = true
        lastError = nil
        defer { isTranslating = false }

        do {
            let response = try await session.translate(text)
            return response.targetText
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }
}

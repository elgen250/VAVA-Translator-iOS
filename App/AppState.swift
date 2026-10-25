import Foundation
import Translation
import Observation

/// Global observable application state for VAVA Translator.
@MainActor
@Observable
public final class AppState {
    public static let shared = AppState()

    /// Currently selected source language (defaults to Auto-Detect)
    public var sourceLanguage: SupportedLanguage = .autoDetect

    /// Currently selected target language (defaults to Arabic)
    public var targetLanguage: SupportedLanguage = .arabic

    /// Pending configuration for SwiftUI .translationTask modifier
    public var translationConfiguration: TranslationSession.Configuration? = nil

    /// Text waiting to be translated via .translationTask
    public var textToTranslate: String = ""

    /// Callback when translation session delivers output
    public var pendingTranslationCompletion: ((String) -> Void)? = nil

    public init() {}

    /// Swaps the source and target languages (if source is not auto-detect).
    public func swapLanguages() {
        guard !sourceLanguage.isAutoDetect else { return }
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
    }

    /// Triggers an on-device translation task through Apple Translation.framework.
    public func requestTranslation(text: String, completion: @escaping (String) -> Void) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        self.textToTranslate = text
        self.pendingTranslationCompletion = completion

        // Resolve source and target locale languages
        let sourceLocale = sourceLanguage.localeLanguage
        let targetLocale = targetLanguage.localeLanguage ?? Locale.Language(identifier: "ar")

        // Invalidate previous configuration safely
        translationConfiguration?.invalidate()

        self.translationConfiguration = TranslationSession.Configuration(
            source: sourceLocale,
            target: targetLocale
        )
    }
}

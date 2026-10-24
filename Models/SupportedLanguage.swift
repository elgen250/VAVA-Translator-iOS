import Foundation

/// Represents a language supported by the iOS 18 on-device Translation framework.
public struct SupportedLanguage: Identifiable, Hashable, Codable, Sendable {
    public let code: String          // e.g. "ar", "en", "es", "auto"
    public let name: String          // English display name
    public let nativeName: String    // Native script name (e.g. "العربية")
    public let flag: String          // Emoji flag icon
    public let isRTL: Bool           // Right-to-left layout flag

    public var id: String { code }

    public init(code: String, name: String, nativeName: String, flag: String, isRTL: Bool = false) {
        self.code = code
        self.name = name
        self.nativeName = nativeName
        self.flag = flag
        self.isRTL = isRTL
    }

    /// Converts to Apple Locale.Language for Translation framework.
    public var localeLanguage: Locale.Language? {
        if isAutoDetect { return nil }
        return Locale.Language(identifier: code)
    }

    /// Whether this represents automatic language detection.
    public var isAutoDetect: Bool {
        code == "auto"
    }

    /// Automatic detection sentinel
    public static let autoDetect = SupportedLanguage(
        code: "auto",
        name: "Auto Detect",
        nativeName: "كشف تلقائي",
        flag: "✨",
        isRTL: false
    )

    /// Arabic (Default primary target for VAVA Translator)
    public static let arabic = SupportedLanguage(
        code: "ar",
        name: "Arabic",
        nativeName: "العربية",
        flag: "🇸🇦",
        isRTL: true
    )

    /// English (Default source language)
    public static let english = SupportedLanguage(
        code: "en",
        name: "English",
        nativeName: "English",
        flag: "🇺🇸",
        isRTL: false
    )

    /// Complete catalog of Apple on-device supported languages
    public static let allLanguages: [SupportedLanguage] = [
        .arabic,
        .english,
        SupportedLanguage(code: "es", name: "Spanish", nativeName: "Español", flag: "🇪🇸"),
        SupportedLanguage(code: "fr", name: "French", nativeName: "Français", flag: "🇫🇷"),
        SupportedLanguage(code: "de", name: "German", nativeName: "Deutsch", flag: "🇩🇪"),
        SupportedLanguage(code: "it", name: "Italian", nativeName: "Italiano", flag: "🇮🇹"),
        SupportedLanguage(code: "pt-BR", name: "Portuguese (Brazil)", nativeName: "Português", flag: "🇧🇷"),
        SupportedLanguage(code: "ru", name: "Russian", nativeName: "Русский", flag: "🇷🇺"),
        SupportedLanguage(code: "zh-Hans", name: "Chinese (Simplified)", nativeName: "简体中文", flag: "🇨🇳"),
        SupportedLanguage(code: "zh-Hant", name: "Chinese (Traditional)", nativeName: "繁體中文", flag: "🇹🇼"),
        SupportedLanguage(code: "ja", name: "Japanese", nativeName: "日本語", flag: "🇯🇵"),
        SupportedLanguage(code: "ko", name: "Korean", nativeName: "한국어", flag: "🇰🇷"),
        SupportedLanguage(code: "hi", name: "Hindi", nativeName: "हिन्दी", flag: "🇮🇳"),
        SupportedLanguage(code: "tr", name: "Turkish", nativeName: "Türkçe", flag: "🇹🇷"),
        SupportedLanguage(code: "vi", name: "Vietnamese", nativeName: "Tiếng Việt", flag: "🇻🇳"),
        SupportedLanguage(code: "th", name: "Thai", nativeName: "ไทย", flag: "🇹🇭"),
        SupportedLanguage(code: "id", name: "Indonesian", nativeName: "Bahasa Indonesia", flag: "🇮🇩"),
        SupportedLanguage(code: "nl", name: "Dutch", nativeName: "Nederlands", flag: "🇳🇱"),
        SupportedLanguage(code: "pl", name: "Polish", nativeName: "Polski", flag: "🇵🇱"),
        SupportedLanguage(code: "uk", name: "Ukrainian", nativeName: "Українська", flag: "🇺🇦")
    ]

    /// Source language choices (includes Auto Detect at top)
    public static var sourceChoices: [SupportedLanguage] {
        [.autoDetect] + allLanguages
    }

    /// Target language choices (excludes Auto Detect)
    public static var targetChoices: [SupportedLanguage] {
        allLanguages
    }

    /// Helper to find a language by its ISO code
    public static func from(code: String) -> SupportedLanguage {
        allLanguages.first { $0.code == code } ?? .english
    }
}

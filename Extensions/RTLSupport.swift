import SwiftUI

/// RTL and Bi-Directional text handling extensions for VAVA Translator.
public extension View {
    /// Forces layout direction according to the language's native script.
    @ViewBuilder
    func vavaLayoutDirection(for language: SupportedLanguage) -> some View {
        self.environment(\.layoutDirection, language.isRTL ? .rightToLeft : .leftToRight)
    }

    /// Aligns text naturally according to the target language (Right for Arabic/RTL, Left for LTR).
    func alignForLanguage(_ language: SupportedLanguage) -> some View {
        self.multilineTextAlignment(language.isRTL ? .trailing : .leading)
            .frame(maxWidth: .infinity, alignment: language.isRTL ? .trailing : .leading)
    }
}

public extension String {
    /// Prefixes right-to-left mark (RLM \u{200F}) if string contains Arabic characters,
    /// ensuring punctuation marks (., !, ?) stay properly docked at the end of the sentence.
    var formattedForBidi: String {
        let hasArabic = self.unicodeScalars.contains { scalar in
            (0x0600...0x06FF).contains(scalar.value) || // Arabic block
            (0x0750...0x077F).contains(scalar.value) || // Arabic supplement
            (0x08A0...0x08FF).contains(scalar.value)    // Arabic extended
        }
        if hasArabic {
            return "\u{200F}" + self
        }
        return self
    }
}

import Foundation
import SwiftData

/// Mock sample data to facilitate immediate Xcode Previews and testing.
public struct SampleData {
    public static func populate(context: ModelContext) {
        let sample1 = TranslationHistoryItem(
            sourceText: "Welcome to our hotel, how can I assist you today?",
            translatedText: "أهلاً بك في فندقنا، كيف يمكنني مساعدتك اليوم؟",
            sourceLanguageCode: "en",
            targetLanguageCode: "ar",
            timestamp: Date().addingTimeInterval(-3600),
            category: "text",
            isFavorite: true
        )

        let sample2 = TranslationHistoryItem(
            sourceText: "أين تقع أقرب محطة قطار؟",
            translatedText: "Where is the nearest train station?",
            sourceLanguageCode: "ar",
            targetLanguageCode: "en",
            timestamp: Date().addingTimeInterval(-7200),
            category: "talk",
            isFavorite: false
        )

        let sample3 = TranslationHistoryItem(
            sourceText: "Menu du Jour: Soupe à l'oignon et Entrecôte grillée",
            translatedText: "قائمة اليوم: حساء البصل وشريحة اللحم المشوية",
            sourceLanguageCode: "fr",
            targetLanguageCode: "ar",
            timestamp: Date().addingTimeInterval(-14400),
            category: "camera",
            isFavorite: true
        )

        context.insert(sample1)
        context.insert(sample2)
        context.insert(sample3)
        try? context.save()
    }
}

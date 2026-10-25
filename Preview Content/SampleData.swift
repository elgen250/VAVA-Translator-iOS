import Foundation
import SwiftData

/// Mock and initial starter data for immediate testing, previews, and first launch.
public struct SampleData {
    @MainActor
    public static func populate(context: ModelContext) {
        // 1. History Items
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

        // 2. Phrase Items for Widget and Coach
        let phrases = [
            PhraseItem(
                id: "phrase_01",
                category: "travel",
                sourceText: "كم تبعد أقرب محطة مترو؟",
                sourceLanguageCode: "ar",
                translatedText: "How far is the nearest metro station?",
                targetLanguageCode: "en",
                phoneticTranscription: "haʊ fɑːr ɪz ðə ˈnɪərɪst ˈmɛtrəʊ ˈsteɪʃən",
                isFavorite: true,
                masteryLevel: 4
            ),
            PhraseItem(
                id: "phrase_02",
                category: "casual",
                sourceText: "سررت بلقائك وأتمنى لك يوماً سعيداً",
                sourceLanguageCode: "ar",
                translatedText: "Nice to meet you and have a wonderful day",
                targetLanguageCode: "en",
                phoneticTranscription: "naɪs tuː miːt juː ænd hæv ə ˈwʌndərfʊl deɪ",
                isFavorite: true,
                masteryLevel: 5
            ),
            PhraseItem(
                id: "phrase_03",
                category: "dining",
                sourceText: "هل يمكنني الحصول على الفاتورة من فضلك؟",
                sourceLanguageCode: "ar",
                translatedText: "Could I have the check please?",
                targetLanguageCode: "en",
                phoneticTranscription: "kʊd aɪ hæv ðə tʃɛk pliːz",
                isFavorite: false,
                masteryLevel: 3
            )
        ]

        for p in phrases {
            context.insert(p)
        }

        // 3. Lesson Progress
        let lesson1 = LessonProgress(
            id: "airport_arrival",
            title: "Airport & Customs",
            subtitle: "الوصول إلى المطار والجوازات",
            topic: "سفر",
            targetLanguageCode: "en",
            totalTurns: 3,
            completedTurns: 3,
            scorePercentage: 1.0,
            isCompleted: true,
            lastPracticedDate: Date()
        )

        let lesson2 = LessonProgress(
            id: "hotel_checkin",
            title: "Hotel Check-In",
            subtitle: "تسجيل الدخول في الفندق",
            topic: "إقامة",
            targetLanguageCode: "en",
            totalTurns: 2,
            completedTurns: 1,
            scorePercentage: 0.5,
            isCompleted: false,
            lastPracticedDate: Date().addingTimeInterval(-86400)
        )

        context.insert(lesson1)
        context.insert(lesson2)

        try? context.save()
    }
}

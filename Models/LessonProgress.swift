import Foundation
import SwiftData

/// SwiftData persistent entity for tracking interactive AI Coach learning progress.
@Model
public final class LessonProgress {
    @Attribute(.unique)
    public var id: String             // e.g. "lesson_airport_arrival"
    public var title: String
    public var subtitle: String
    public var topic: String          // "Airport", "Restaurant", "Hotel", "Business"
    public var targetLanguageCode: String
    public var totalTurns: Int
    public var completedTurns: Int
    public var scorePercentage: Double
    public var isCompleted: Bool
    public var lastPracticedDate: Date

    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        topic: String,
        targetLanguageCode: String = "en",
        totalTurns: Int = 5,
        completedTurns: Int = 0,
        scorePercentage: Double = 0.0,
        isCompleted: Bool = false,
        lastPracticedDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.topic = topic
        self.targetLanguageCode = targetLanguageCode
        self.totalTurns = totalTurns
        self.completedTurns = completedTurns
        self.scorePercentage = scorePercentage
        self.isCompleted = isCompleted
        self.lastPracticedDate = lastPracticedDate
    }

    public var progressFraction: Double {
        guard totalTurns > 0 else { return 0 }
        return Double(completedTurns) / Double(totalTurns)
    }
}

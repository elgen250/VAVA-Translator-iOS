import Foundation
import AppIntents
import WidgetKit

/// AppIntent allowing users to cycle through daily vocabulary phrases directly from the home screen widget.
public struct VAVANextPhraseIntent: AppIntent {
    public static var title: LocalizedStringResource = "العبارة التالية"
    public static var description = IntentDescription("الانتقال إلى العبارة التالية في الويدجت")

    public init() {}

    public func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.vava.translator") ?? UserDefaults.standard
        let currentIndex = defaults.integer(forKey: "vava_widget_phrase_index")
        let nextIndex = (currentIndex + 1) % 4
        defaults.set(nextIndex, forKey: "vava_widget_phrase_index")
        defaults.set(false, forKey: "vava_widget_phrase_revealed")

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

/// AppIntent allowing users to toggle/reveal the translation on the interactive widget.
public struct VAVAToggleRevealIntent: AppIntent {
    public static var title: LocalizedStringResource = "إظهار الترجمة"
    public static var description = IntentDescription("كشف أو إخفاء ترجمة العبارة الحالية")

    public init() {}

    public func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.vava.translator") ?? UserDefaults.standard
        let isRevealed = defaults.bool(forKey: "vava_widget_phrase_revealed")
        defaults.set(!isRevealed, forKey: "vava_widget_phrase_revealed")

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

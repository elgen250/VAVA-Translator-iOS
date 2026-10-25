import WidgetKit
import SwiftUI
import AppIntents

public struct WidgetPhraseItem: Sendable {
    public let arabic: String
    public let english: String
    public let category: String
    public let phonetic: String

    public init(arabic: String, english: String, category: String, phonetic: String) {
        self.arabic = arabic
        self.english = english
        self.category = category
        self.phonetic = phonetic
    }
}

public struct PhraseWidgetEntry: TimelineEntry {
    public let date: Date
    public let phrase: WidgetPhraseItem
    public let isRevealed: Bool
    public let currentIndex: Int
    public let totalPhrases: Int

    public init(
        date: Date,
        phrase: WidgetPhraseItem,
        isRevealed: Bool,
        currentIndex: Int,
        totalPhrases: Int
    ) {
        self.date = date
        self.phrase = phrase
        self.isRevealed = isRevealed
        self.currentIndex = currentIndex
        self.totalPhrases = totalPhrases
    }
}

public struct VAVAWidgetProvider: TimelineProvider {
    public static let fallbackPhrases: [WidgetPhraseItem] = [
        WidgetPhraseItem(
            arabic: "سررت بلقائك وأتمنى لك يوماً جميلاً",
            english: "Nice to meet you and have a wonderful day",
            category: "يوميات",
            phonetic: "naɪs tuː miːt juː ænd hæv ə ˈwʌndərfʊl deɪ"
        ),
        WidgetPhraseItem(
            arabic: "كم تبعد أقرب محطة مترو من هنا؟",
            english: "How far is the nearest metro station?",
            category: "سفر",
            phonetic: "haʊ fɑːr ɪz ðə ˈnɪərɪst ˈmɛtrəʊ ˈsteɪʃən"
        ),
        WidgetPhraseItem(
            arabic: "هل يمكنني دفع الحساب ببطاقة الائتمان؟",
            english: "May I pay the bill with credit card?",
            category: "مطعم",
            phonetic: "meɪ aɪ peɪ ðə bɪl wɪð ˈkrɛdɪt kɑːd"
        ),
        WidgetPhraseItem(
            arabic: "أبحث عن صيدلية مناوبة في هذا الحي",
            english: "I am looking for an on-duty pharmacy",
            category: "طوارئ",
            phonetic: "aɪ æm ˈlʊkɪŋ fɔːr ən ɒn-ˈdjuːti ˈfɑːrməsi"
        )
    ]

    public func placeholder(in context: Context) -> PhraseWidgetEntry {
        PhraseWidgetEntry(
            date: Date(),
            phrase: Self.fallbackPhrases[0],
            isRevealed: false,
            currentIndex: 0,
            totalPhrases: Self.fallbackPhrases.count
        )
    }

    public func getSnapshot(in context: Context, completion: @escaping (PhraseWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<PhraseWidgetEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.vava.translator") ?? UserDefaults.standard
        let index = defaults.integer(forKey: "vava_widget_phrase_index") % Self.fallbackPhrases.count
        let isRevealed = defaults.bool(forKey: "vava_widget_phrase_revealed")

        let entry = PhraseWidgetEntry(
            date: Date(),
            phrase: Self.fallbackPhrases[index],
            isRevealed: isRevealed,
            currentIndex: index,
            totalPhrases: Self.fallbackPhrases.count
        )

        // Refresh every 2 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date().addingTimeInterval(7200)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

public struct VAVAInteractiveWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: VAVAWidgetProvider.Entry

    public var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallWidgetView
            case .systemMedium:
                mediumWidgetView
            case .systemLarge:
                largeWidgetView
            case .accessoryRectangular:
                accessoryRectangularView
            default:
                mediumWidgetView
            }
        }
        .containerBackground(for: .widget) {
            Color(UIColor.secondarySystemBackground)
        }
    }

    // MARK: - Small Widget
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.phrase.category)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.15))
                    .foregroundStyle(Color.blue)
                    .clipShape(Capsule())

                Spacer()

                Button(intent: VAVANextPhraseIntent()) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Text(entry.phrase.arabic)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)

            if entry.isRevealed {
                Text(entry.phrase.english)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.blue)
                    .lineLimit(2)
            } else {
                Button(intent: VAVAToggleRevealIntent()) {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 10))
                        Text("كشف الترجمة")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.12))
                    .foregroundStyle(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
    }

    // MARK: - Medium Widget
    private var mediumWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundStyle(Color.blue)
                    Text("عبارة اليوم • \(entry.phrase.category)")
                        .font(.caption2.bold())
                        .foregroundStyle(Color.blue)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button(intent: VAVAToggleRevealIntent()) {
                        Image(systemName: entry.isRevealed ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.blue)
                    }
                    .buttonStyle(.plain)

                    Button(intent: VAVANextPhraseIntent()) {
                        Image(systemName: "arrow.forward.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.blue)
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.phrase.arabic)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if entry.isRevealed {
                    Text(entry.phrase.english)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.blue)
                        .lineLimit(1)

                    Text(entry.phrase.phonetic)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text("المس زر العين أعلاه لكشف الترجمة والنطق...")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }

            Spacer()

            HStack {
                Text("\(entry.currentIndex + 1) من \(entry.totalPhrases)")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("VAVA Translator")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(4)
    }

    // MARK: - Large Widget
    private var largeWidgetView: some View {
        VStack(alignment: .leading, spacing: 10) {
            mediumWidgetView

            Divider()

            Text("موقف تدريبي مقترح من James")
                .font(.caption.bold())
                .foregroundStyle(.primary)

            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.title2)
                    .foregroundStyle(Color.blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Airport & Customs • في المطار")
                        .font(.subheadline.bold())
                    Text("تدرّب على تقديم الجواز والإجابة عن وجهتك")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(10)
            .background(Color(UIColor.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
    }

    // MARK: - Accessory Rectangular (Lock Screen)
    private var accessoryRectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "globe")
                    .font(.caption2)
                Text(entry.phrase.arabic)
                    .font(.caption.bold())
                    .lineLimit(1)
            }
            Text(entry.isRevealed ? entry.phrase.english : "المس لفتح VAVA")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

public struct VAVAInteractiveWidget: Widget {
    public let kind: String = "VAVAInteractiveWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VAVAWidgetProvider()) { entry in
            VAVAInteractiveWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("عبارة اليوم التفاعلية")
        .description("تعلم عبارات يومية مترجمة وتحكّم في كشفها مباشرة من شاشتك الرئيسية.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
    }
}

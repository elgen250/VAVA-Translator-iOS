import SwiftUI
import SwiftData

/// AI Coach James screen for interactive language practice and speaking drills.
public struct CoachJamesView: View {
    @Query private var lessonProgressList: [LessonProgress]
    @Query private var phraseList: [PhraseItem]
    @State private var selectedScenario: CoachScenario?
    @State private var selectedCategory: String = "الكل"

    private let scenarios = CoachJamesService.sampleScenarios
    private let categories = ["الكل", "سفر", "إقامة", "يوميات"]

    public init() {}

    private var filteredScenarios: [CoachScenario] {
        if selectedCategory == "الكل" {
            return scenarios
        }
        return scenarios.filter { $0.category == selectedCategory }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Coach Hero Header
                    coachHeaderCard

                    // Daily Streak & Mastery Stats Card
                    statsRowCard

                    // Category Filter Pills
                    categoryPicker

                    // Scenarios Grid / List
                    scenariosSection

                    // Daily Practice Phrases
                    dailyPhrasesSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.vavaBackground.ignoresSafeArea())
            .navigationTitle("المدرب James")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedScenario) { scenario in
                NavigationStack {
                    LessonDetailView(scenario: scenario)
                }
            }
        }
    }

    // MARK: - Coach Header Card
    private var coachHeaderCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient.vavaHero)
                    .frame(width: 64, height: 64)

                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("المدرب James")
                        .font(.title3.bold())
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Text("AI Coach")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.vavaPrimary.opacity(0.12))
                        .foregroundStyle(Color.vavaPrimary)
                        .clipShape(Capsule())
                }

                Text("تدرّب على المحادثات الحقيقية وصحح نطقك بالذكاء الاصطناعي على جهازك.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.vavaBorder, lineWidth: 1)
        )
    }

    // MARK: - Stats Row
    private var statsRowCard: some View {
        HStack(spacing: 12) {
            StatMetricItem(
                icon: "flame.fill",
                iconColor: .orange,
                value: "3 أيام",
                label: "الممارسة المتواصلة"
            )

            Divider()
                .frame(height: 36)

            StatMetricItem(
                icon: "checkmark.seal.fill",
                iconColor: Color.vavaPrimary,
                value: "\(completedLessonsCount)/\(scenarios.count)",
                label: "المواقف المكتملة"
            )

            Divider()
                .frame(height: 36)

            StatMetricItem(
                icon: "chart.line.uptrend.xyaxis",
                iconColor: .green,
                value: "92%",
                label: "دقة النطق"
            )
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.vavaBorder, lineWidth: 1)
        )
    }

    private var completedLessonsCount: Int {
        lessonProgressList.filter { $0.isCompleted }.count
    }

    // MARK: - Category Filter Pills
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { cat in
                    Button {
                        withAnimation(.snappy(duration: 0.25)) {
                            selectedCategory = cat
                        }
                    } label: {
                        Text(cat)
                            .font(.subheadline.weight(selectedCategory == cat ? .semibold : .regular))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == cat
                                ? Color.vavaPrimary
                                : Color.vavaCardBackground
                            )
                            .foregroundStyle(
                                selectedCategory == cat
                                ? Color.white
                                : Color.primary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selectedCategory == cat ? Color.clear : Color.vavaBorder, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Scenarios Section
    private var scenariosSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("المواقف التدريبية")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Spacer()
                Text("\(filteredScenarios.count) دروس")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                ForEach(filteredScenarios) { scenario in
                    ScenarioRowView(scenario: scenario) {
                        selectedScenario = scenario
                    }
                }
            }
        }
    }

    // MARK: - Daily Phrases Section
    private var dailyPhrasesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("عبارات اليوم المقترحة")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.vavaPrimary)
            }

            VStack(spacing: 10) {
                CoachPhraseCard(
                    arabic: "هل يمكنك التحدث ببطء أكثر من فضلك؟",
                    english: "Could you please speak a little slower?",
                    phonetic: "kʊd juː pliːz spiːk ə ˈlɪtl ˈsləʊə"
                )

                CoachPhraseCard(
                    arabic: "أنا هنا لقضاء عطلة قصيرة مع عائلتي.",
                    english: "I am here on a short holiday with my family.",
                    phonetic: "aɪ æm hɪər ɒn ə ʃɔːt ˈhɒlədeɪ wɪð maɪ ˈfæmɪli"
                )

                CoachPhraseCard(
                    arabic: "كم ثمن هذه الوجبة مع الضريبة؟",
                    english: "How much is this meal including tax?",
                    phonetic: "haʊ mʌtʃ ɪz ðɪs miːl ɪnˈkluːdɪŋ tæks"
                )
            }
        }
    }
}

// MARK: - Scenario Row View
private struct ScenarioRowView: View {
    let scenario: CoachScenario
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.vavaPrimary.opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: scenario.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(Color.vavaPrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(scenario.titleAr)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Text(scenario.category)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    Text(scenario.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "waveform")
                            .font(.caption2)
                            .foregroundStyle(Color.vavaPrimary)
                        Text("\(scenario.turns.count) جولات حوارية")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Image(systemName: "chevron.left")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color.vavaCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.vavaBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Coach Phrase Card
private struct CoachPhraseCard: View {
    let arabic: String
    let english: String
    let phonetic: String

    @State private var isPlaying = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(arabic)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.primary)

                    Text(english)
                        .font(.caption)
                        .foregroundStyle(Color.vavaPrimary)

                    Text(phonetic)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    AudioPlaybackService.shared.speak(text: english, languageCode: "en")
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 14))
                        .padding(10)
                        .background(Color.vavaPrimary.opacity(0.1))
                        .foregroundStyle(Color.vavaPrimary)
                        .clipShape(Circle())
                }
            }
        }
        .padding(14)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.vavaBorder, lineWidth: 1)
        )
    }
}

// MARK: - Stat Metric Item
private struct StatMetricItem: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(iconColor)
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.primary)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

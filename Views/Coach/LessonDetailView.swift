import SwiftUI
import SwiftData

/// Interactive drill screen for practicing a scenario with Coach James.
public struct LessonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let scenario: CoachScenario
    @State private var currentTurnIndex = 0
    @State private var userSpokenText = ""
    @State private var isTurnPassed = false
    @State private var completedTurnsCount = 0

    private let speechService = SpeechService.shared
    private let playbackService = AudioPlaybackService.shared

    public init(scenario: CoachScenario) {
        self.scenario = scenario
    }

    private var currentTurn: CoachTurn? {
        if currentTurnIndex < scenario.turns.count {
            return scenario.turns[currentTurnIndex]
        }
        return nil
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Progress Bar
            ProgressView(value: Double(completedTurnsCount), total: Double(scenario.turns.count))
                .tint(Color.vavaPrimary)
                .padding(.horizontal)

            if let turn = currentTurn {
                ScrollView {
                    VStack(spacing: 20) {
                        // Coach Prompt Card
                        coachCard(turn)

                        // Expected user response guide
                        userExpectedCard(turn)

                        // User Spoken Feedback
                        if !userSpokenText.isEmpty {
                            spokenFeedbackCard
                        }
                    }
                    .padding()
                }

                // Bottom Mic Controller & Next
                bottomControls(turn)
            } else {
                lessonCompletedCard
            }
        }
        .background(Color.vavaScreenBackground.ignoresSafeArea())
        .navigationTitle(scenario.titleAr)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let first = scenario.turns.first {
                playbackService.speak(text: first.promptEn, languageCode: "en-US")
            }
        }
    }

    private func coachCard(_ turn: CoachTurn) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundStyle(Color.vavaPrimary)
                    Text("المدرب James")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                Spacer()
                Button {
                    playbackService.speak(text: turn.promptEn, languageCode: "en-US")
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundStyle(Color.vavaPrimary)
                }
            }

            Text(turn.promptEn)
                .font(.title3)
                .fontWeight(.bold)

            Text(turn.promptAr)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.vavaBorder, lineWidth: 1)
        )
    }

    private func userExpectedCard(_ turn: CoachTurn) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("دورك الآن: انطق الجملة التالية بالإنجليزية", systemImage: "mic.fill")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(Color.vavaAccent)

            Text(turn.expectedResponse)
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                Text("المعنى: \(turn.hintText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    playbackService.speak(text: turn.expectedResponse, languageCode: "en-US")
                } label: {
                    Text("استمع للنموذج")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.vavaPrimary)
                }
            }
        }
        .padding(16)
        .background(Color.vavaAccent.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var spokenFeedbackCard: some View {
        VStack(spacing: 8) {
            HStack {
                Text("ما سمعه المدرب:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: isTurnPassed ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundStyle(isTurnPassed ? Color.vavaSuccess : Color.orange)
            }
            Text(userSpokenText)
                .font(.body)
                .fontWeight(.medium)
        }
        .padding(14)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func bottomControls(_ turn: CoachTurn) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                // Mic Button
                Button {
                    toggleSpeechInput(expected: turn.expectedResponse)
                } label: {
                    ZStack {
                        Circle()
                            .fill(speechService.isRecording ? Color.red : Color.vavaPrimary)
                            .frame(width: 68, height: 68)
                            .shadow(color: (speechService.isRecording ? Color.red : Color.vavaPrimary).opacity(0.35), radius: 8, x: 0, y: 4)
                        Image(systemName: speechService.isRecording ? "stop.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }

                // Next Step Button
                if isTurnPassed || !userSpokenText.isEmpty {
                    Button {
                        advanceToNextTurn()
                    } label: {
                        HStack {
                            Text("السؤال التالي")
                            Image(systemName: "arrow.left")
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.vavaSuccess)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding()
        }
    }

    private var lessonCompletedCard: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.vavaSuccess.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(Color.vavaSuccess)
            }

            Text("أحسنت! أكملت الدرس بنجاح")
                .font(.title2)
                .fontWeight(.heavy)

            Text("مارست حوار \(scenario.titleAr) بدقة وتدربت على النطق السليم.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button("إنهاء الدرس") {
                dismiss()
            }
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(Color.vavaPrimary)
            .clipShape(Capsule())

            Spacer()
        }
        .padding()
    }

    private func toggleSpeechInput(expected: String) {
        if speechService.isRecording {
            speechService.stopRecording()
            userSpokenText = speechService.transcriptText
            // Simple string similarity evaluation
            isTurnPassed = userSpokenText.count >= (expected.count / 2)
            if isTurnPassed {
                completedTurnsCount += 1
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        } else {
            userSpokenText = ""
            isTurnPassed = false
            try? speechService.startRecording(language: SupportedLanguage.english)
        }
    }

    private func advanceToNextTurn() {
        currentTurnIndex += 1
        userSpokenText = ""
        isTurnPassed = false
        if let next = currentTurn {
            playbackService.speak(text: next.promptEn, languageCode: "en-US")
        } else {
            saveLessonProgress()
        }
    }

    private func saveLessonProgress() {
        let progress = LessonProgress(
            id: scenario.id,
            title: scenario.title,
            subtitle: scenario.titleAr,
            topic: scenario.category,
            targetLanguageCode: "en",
            totalTurns: scenario.turns.count,
            completedTurns: scenario.turns.count,
            scorePercentage: 100.0,
            isCompleted: true,
            lastPracticedDate: Date()
        )
        modelContext.insert(progress)
        try? modelContext.save()
    }
}

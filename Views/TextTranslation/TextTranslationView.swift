import SwiftUI
import SwiftData
import Translation

/// Primary Text Translation Tab View.
public struct TextTranslationView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var appState: AppState

    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var isTranslating: Bool = false
    @State private var isCurrentFavorite: Bool = false
    @State private var currentHistoryItem: TranslationHistoryItem? = nil

    private let translationService = TranslationService.shared
    private let speechService = SpeechService.shared
    private let playbackService = AudioPlaybackService.shared

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 1. Language Selector Header
                    LanguageSelectorBar(appState: appState)
                        .padding(.top, 8)

                    // 2. Source Text Input Card
                    sourceInputCard

                    // 3. Action Translate Button
                    translateActionButton

                    // 4. Translation Output Card
                    TranslationResultCard(
                        translatedText: outputText,
                        targetLanguage: appState.targetLanguage,
                        isTranslating: isTranslating,
                        isFavorite: isCurrentFavorite,
                        onToggleFavorite: toggleFavorite
                    )

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(Color.vavaScreenBackground.ignoresSafeArea())
            .navigationTitle("VAVA الترجمة")
            .navigationBarTitleDisplayMode(.inline)
            // iOS 18 Native Apple Translation Task
            .translationTask(appState.translationConfiguration) { session in
                do {
                    isTranslating = true
                    let translated = try await translationService.translate(
                        text: appState.textToTranslate,
                        using: session
                    )
                    await MainActor.run {
                        self.outputText = translated
                        self.isTranslating = false
                        self.appState.pendingTranslationCompletion?(translated)
                        self.saveToHistory(source: appState.textToTranslate, result: translated)
                    }
                } catch {
                    await MainActor.run {
                        self.isTranslating = false
                    }
                }
            }
            .onChange(of: speechService.transcriptText) { _, newTranscript in
                if speechService.isRecording && !newTranscript.isEmpty {
                    inputText = newTranscript
                }
            }
            .onChange(of: inputText) { _, newText in
                // Handle live language detection if auto-detect is chosen
                if appState.sourceLanguage.isAutoDetect {
                    _ = translationService.detectLanguage(for: newText)
                }
            }
        }
    }

    // MARK: - Subviews

    private var sourceInputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Card Subhead & Helpers
            HStack {
                if appState.sourceLanguage.isAutoDetect, let detected = translationService.detectedLanguage {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("تم التعرف: \(detected.nativeName)")
                    }
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.vavaPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.vavaPrimary.opacity(0.12))
                    .clipShape(Capsule())
                }

                Spacer()

                // Paste button if input is empty
                if inputText.isEmpty {
                    Button("لصق") {
                        if let pasted = UIPasteboard.general.string {
                            inputText = pasted
                        }
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.vavaPrimary)
                } else {
                    // Clear button
                    Button {
                        inputText = ""
                        outputText = ""
                        currentHistoryItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Input Text Field
            TextField("اكتب هنا ما تريد ترجمته...", text: $inputText, axis: .vertical)
                .font(.body)
                .lineLimit(4...8)
                .alignForLanguage(resolvedSourceLanguage)
                .vavaLayoutDirection(for: resolvedSourceLanguage)

            Divider()
                .opacity(0.5)

            // Bottom Tools: Character Count & Mic
            HStack {
                Text("\(inputText.count) حرف")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Spacer()

                // Dictation Mic Button
                Button {
                    handleDictationToggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: speechService.isRecording ? "waveform" : "mic.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(speechService.isRecording ? .white : Color.vavaPrimary)
                            .symbolEffect(.pulse, isActive: speechService.isRecording)
                        if speechService.isRecording {
                            Text("جار الاستماع...")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(speechService.isRecording ? Color.red : Color.vavaPrimary.opacity(0.1))
                    .clipShape(Capsule())
                }
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

    private var translateActionButton: some View {
        Button {
            triggerTranslation()
        } label: {
            HStack(spacing: 8) {
                if isTranslating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "translate")
                        .font(.headline)
                    Text("ترجمة فورية")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(inputText.isEmpty ? Color.secondary.opacity(0.3) : Color.vavaPrimary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: inputText.isEmpty ? .clear : Color.vavaPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTranslating)
    }

    // MARK: - Logic Helpers

    private var resolvedSourceLanguage: SupportedLanguage {
        if appState.sourceLanguage.isAutoDetect {
            return translationService.detectedLanguage ?? .english
        }
        return appState.sourceLanguage
    }

    private func triggerTranslation() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        appState.requestTranslation(text: inputText) { result in
            self.outputText = result
        }
    }

    private func handleDictationToggle() {
        if speechService.isRecording {
            speechService.stopRecording()
        } else {
            do {
                try speechService.startRecording(language: resolvedSourceLanguage)
            } catch {
                print("Error starting dictation: \(error)")
            }
        }
    }

    private func saveToHistory(source: String, result: String) {
        let item = TranslationHistoryItem(
            sourceText: source,
            translatedText: result,
            sourceLanguageCode: resolvedSourceLanguage.code,
            targetLanguageCode: appState.targetLanguage.code,
            category: "text",
            isFavorite: false
        )
        modelContext.insert(item)
        try? modelContext.save()
        currentHistoryItem = item
        isCurrentFavorite = false
    }

    private func toggleFavorite() {
        isCurrentFavorite.toggle()
        if let currentHistoryItem {
            currentHistoryItem.isFavorite = isCurrentFavorite
            try? modelContext.save()
        }
    }
}

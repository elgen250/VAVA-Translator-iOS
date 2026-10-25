import SwiftUI
import SwiftData

/// Interactive live conversation view for two participants speaking different languages.
public struct TalkConversationView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var appState: AppState

    @State private var messages: [ConversationMessage] = []
    @State private var activeSpeaker: SpeakerSide? = nil
    @State private var isProcessingTranslation = false

    private let speechService = SpeechService.shared
    private let playbackService = AudioPlaybackService.shared

    // Languages assigned to the two speakers
    @State private var speaker1Language: SupportedLanguage = .arabic
    @State private var speaker2Language: SupportedLanguage = .english

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Language Configuration Bar
                conversationHeader
                    .padding()
                    .background(Color.vavaCardBackground)

                // Conversation Messages Scroll Area
                if messages.isEmpty {
                    emptyConversationPlaceholder
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(messages) { msg in
                                    ConversationBubbleView(message: msg) {
                                        playbackService.speak(
                                            text: msg.translatedText,
                                            languageCode: msg.targetLanguage.code
                                        )
                                    }
                                    .id(msg.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _, _ in
                            if let last = messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                Divider()

                // Dual Microphone Controllers Bar
                dualMicControlBar
                    .padding()
                    .background(Color.vavaCardBackground)
            }
            .background(Color.vavaScreenBackground.ignoresSafeArea())
            .navigationTitle("محادثة صوتية حية")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !messages.isEmpty {
                        Button("جديد") {
                            withAnimation { messages.removeAll() }
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.vavaPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var conversationHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Text(speaker1Language.flag)
                Text(speaker1Language.nativeName)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            Spacer()
            Image(systemName: "arrow.left.and.right")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 6) {
                Text(speaker2Language.nativeName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(speaker2Language.flag)
            }
        }
        .padding(.horizontal, 8)
    }

    private var emptyConversationPlaceholder: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 64))
                .foregroundStyle(LinearGradient.vavaHero)
            Text("محادثة فورية بين شخصين")
                .font(.title3)
                .fontWeight(.bold)
            Text("اضغط مطولاً أو انقر على ميكروفون المتحدث للبدء، وسيترجم التطبيق الكلام وينطقه صوتياً فوراً.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private var dualMicControlBar: some View {
        HStack(spacing: 20) {
            // Speaker 1 Mic Button
            speakerMicButton(
                side: .primary,
                lang: speaker1Language,
                targetLang: speaker2Language
            )

            // Speaker 2 Mic Button
            speakerMicButton(
                side: .secondary,
                lang: speaker2Language,
                targetLang: speaker1Language
            )
        }
    }

    private func speakerMicButton(
        side: SpeakerSide,
        lang: SupportedLanguage,
        targetLang: SupportedLanguage
    ) -> some View {
        let isCurrentRecording = activeSpeaker == side && speechService.isRecording

        return Button {
            handleMicTap(side: side, lang: lang, targetLang: targetLang)
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    if isCurrentRecording {
                        Circle()
                            .stroke(Color.red.opacity(0.3), lineWidth: 8)
                            .frame(width: 76, height: 76)
                            .scaleEffect(1.2)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isCurrentRecording)
                    }

                    Circle()
                        .fill(isCurrentRecording ? Color.red : (side == .primary ? Color.vavaPrimary : Color.vavaAccent))
                        .frame(width: 64, height: 64)
                        .shadow(color: (isCurrentRecording ? Color.red : Color.vavaPrimary).opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: isCurrentRecording ? "stop.fill" : "mic.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                HStack(spacing: 4) {
                    Text(lang.flag)
                    Text(isCurrentRecording ? "جار الاستماع..." : lang.nativeName)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Logic

    private func handleMicTap(side: SpeakerSide, lang: SupportedLanguage, targetLang: SupportedLanguage) {
        if activeSpeaker == side && speechService.isRecording {
            // Stop and translate
            speechService.stopRecording()
            let spoken = speechService.transcriptText
            activeSpeaker = nil

            if !spoken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                translateAndAddMessage(spoken: spoken, side: side, from: lang, to: targetLang)
            }
        } else {
            // Start recording for this speaker
            activeSpeaker = side
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            do {
                try speechService.startRecording(language: lang)
            } catch {
                print("Failed to start talk recording: \(error)")
                activeSpeaker = nil
            }
        }
    }

    private func translateAndAddMessage(spoken: String, side: SpeakerSide, from: SupportedLanguage, to: SupportedLanguage) {
        isProcessingTranslation = true
        
        // Use AppState to request translation
        appState.sourceLanguage = from
        appState.targetLanguage = to
        appState.requestTranslation(text: spoken) { translated in
            let newMessage = ConversationMessage(
                speaker: side,
                originalText: spoken,
                translatedText: translated,
                sourceLanguage: from,
                targetLanguage: to
            )
            self.messages.append(newMessage)
            self.isProcessingTranslation = false

            // Auto-speak translated output for the other party
            self.playbackService.speak(text: translated, languageCode: to.code)

            // Save conversation turn to SwiftData history
            let historyItem = TranslationHistoryItem(
                sourceText: spoken,
                translatedText: translated,
                sourceLanguageCode: from.code,
                targetLanguageCode: to.code,
                category: "talk"
            )
            self.modelContext.insert(historyItem)
            try? self.modelContext.save()
        }
    }
}

import SwiftUI

/// Card displaying the translated text output with actions for speech, copy, and favorite.
public struct TranslationResultCard: View {
    let translatedText: String
    let targetLanguage: SupportedLanguage
    let isTranslating: Bool
    let onToggleFavorite: () -> Void
    let isFavorite: Bool

    @State private var copiedNotice = false
    private let playbackService = AudioPlaybackService.shared

    public init(
        translatedText: String,
        targetLanguage: SupportedLanguage,
        isTranslating: Bool,
        isFavorite: Bool,
        onToggleFavorite: @escaping () -> Void
    ) {
        self.translatedText = translatedText
        self.targetLanguage = targetLanguage
        self.isTranslating = isTranslating
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Bar
            HStack {
                HStack(spacing: 8) {
                    Text(targetLanguage.flag)
                    Text(targetLanguage.nativeName)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.vavaPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.vavaPrimary.opacity(0.12))
                .clipShape(Capsule())

                Spacer()

                if !translatedText.isEmpty && !isTranslating {
                    HStack(spacing: 16) {
                        // Speaker (TTS) Button
                        Button {
                            if playbackService.isSpeaking {
                                playbackService.stop()
                            } else {
                                playbackService.speak(text: translatedText, languageCode: targetLanguage.code)
                            }
                        } label: {
                            Image(systemName: playbackService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(playbackService.isSpeaking ? Color.vavaPrimary : Color.secondary)
                                .symbolEffect(.variableColor.iterative, isActive: playbackService.isSpeaking)
                        }

                        // Copy Button
                        Button {
                            UIPasteboard.general.string = translatedText
                            copiedNotice = true
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                copiedNotice = false
                            }
                        } label: {
                            Image(systemName: copiedNotice ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(copiedNotice ? Color.vavaSuccess : Color.secondary)
                        }

                        // Favorite Star Button
                        Button {
                            onToggleFavorite()
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        } label: {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(isFavorite ? Color.yellow : Color.secondary)
                        }
                    }
                }
            }

            Divider()
                .opacity(0.6)

            // Content Body
            if isTranslating {
                HStack(spacing: 12) {
                    ProgressView()
                        .tint(Color.vavaPrimary)
                    Text("جاري الترجمة عصبياً على الجهاز...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 70, alignment: .center)
            } else if translatedText.isEmpty {
                Text("ستظهر نتيجة الترجمة هنا فور إدخال النص...")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
            } else {
                Text(translatedText.formattedForBidi)
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(.primary)
                    .alignForLanguage(targetLanguage)
                    .lineSpacing(4)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: targetLanguage.isRTL ? .trailing : .leading)
            }
        }
        .padding(18)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.vavaBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
    }
}

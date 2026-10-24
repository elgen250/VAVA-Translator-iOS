import SwiftUI

/// Message bubble for the live dual-speaker conversation mode.
public struct ConversationBubbleView: View {
    let message: ConversationMessage
    let onPlayAudio: () -> Void

    private let playbackService = AudioPlaybackService.shared

    public init(message: ConversationMessage, onPlayAudio: @escaping () -> Void) {
        self.message = message
        self.onPlayAudio = onPlayAudio
    }

    private var isPrimary: Bool {
        message.speaker == .primary
    }

    public var body: some View {
        HStack {
            if isPrimary { Spacer(minLength: 40) }

            VStack(alignment: isPrimary ? .trailing : .leading, spacing: 6) {
                // Header (Speaker Name + Flags)
                HStack(spacing: 6) {
                    Text(message.speaker.title)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(isPrimary ? Color.vavaPrimary : Color.secondary)

                    Text("\(message.sourceLanguage.flag) ➔ \(message.targetLanguage.flag)")
                        .font(.caption2)

                    Spacer()

                    // Play audio button
                    Button {
                        onPlayAudio()
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.caption)
                            .foregroundStyle(Color.vavaPrimary)
                    }
                }

                // Original Speech Text
                Text(message.originalText.formattedForBidi)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .alignForLanguage(message.sourceLanguage)

                Divider()
                    .opacity(0.3)

                // Translated Text
                Text(message.translatedText.formattedForBidi)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .alignForLanguage(message.targetLanguage)
            }
            .padding(14)
            .background(
                isPrimary 
                    ? Color.vavaPrimary.opacity(0.12)
                    : Color.vavaCardBackground
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isPrimary ? Color.vavaPrimary.opacity(0.25) : Color.vavaBorder,
                        lineWidth: 1
                    )
            )

            if !isPrimary { Spacer(minLength: 40) }
        }
    }
}

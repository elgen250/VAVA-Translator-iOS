import SwiftUI

/// Single row item in the History / Favorites list.
public struct HistoryRowView: View {
    let item: TranslationHistoryItem
    let onToggleFavorite: () -> Void
    let onPlayAudio: () -> Void

    public init(
        item: TranslationHistoryItem,
        onToggleFavorite: @escaping () -> Void,
        onPlayAudio: @escaping () -> Void
    ) {
        self.item = item
        self.onToggleFavorite = onToggleFavorite
        self.onPlayAudio = onPlayAudio
    }

    private var categoryIcon: String {
        switch item.category {
        case "talk": return "bubble.left.and.bubble.right"
        case "camera": return "camera.viewfinder"
        default: return "character.bubble"
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header (Flags, Languages, Category Badge & Favorite Star)
            HStack {
                HStack(spacing: 6) {
                    Text(item.sourceLanguage.flag)
                    Text("➔")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Text(item.targetLanguage.flag)
                    Text("\(item.sourceLanguage.nativeName) إلى \(item.targetLanguage.nativeName)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Category Icon
                Image(systemName: categoryIcon)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                // Favorite Star
                Button {
                    onToggleFavorite()
                } label: {
                    Image(systemName: item.isFavorite ? "star.fill" : "star")
                        .font(.subheadline)
                        .foregroundStyle(item.isFavorite ? Color.yellow : Color.secondary)
                }
                .buttonStyle(.plain)
            }

            // Source Text
            Text(item.sourceText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .alignForLanguage(item.sourceLanguage)

            // Translated Text
            HStack(alignment: .bottom) {
                Text(item.translatedText.formattedForBidi)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .alignForLanguage(item.targetLanguage)

                Spacer()

                // Audio Playback Button
                Button {
                    onPlayAudio()
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption)
                        .foregroundStyle(Color.vavaPrimary)
                        .padding(6)
                        .background(Color.vavaPrimary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            // Timestamp
            HStack {
                Spacer()
                Text(item.timestamp, format: .dateTime.month().day().hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.vavaBorder, lineWidth: 1)
        )
    }
}

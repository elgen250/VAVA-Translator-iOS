import SwiftUI
import PhotosUI
import SwiftData

/// Camera and Photo OCR Translation View using PhotosUI and Apple Vision.framework.
public struct CameraOCRView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var appState: AppState

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isExtractingText = false
    @State private var extractedText = ""
    @State private var translatedOCRText = ""
    @State private var isTranslating = false

    private let visionService = VisionOCRService.shared
    private let playbackService = AudioPlaybackService.shared

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Target Language Quick Bar
                    HStack {
                        Text("ترجمة النصوص المستخرجة إلى:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack(spacing: 6) {
                            Text(appState.targetLanguage.flag)
                            Text(appState.targetLanguage.nativeName)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.vavaPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.vavaPrimary.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal)

                    // Image Picker / Preview Card
                    if let selectedImage {
                        imagePreviewCard(selectedImage)
                    } else {
                        photoPickerPlaceholderCard
                    }

                    // Extracted Text Card (if text was detected)
                    if !extractedText.isEmpty {
                        extractedTextCard
                    }

                    // Translated Result Card
                    if !translatedOCRText.isEmpty || isTranslating {
                        translatedOutputCard
                    }

                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .background(Color.vavaScreenBackground.ignoresSafeArea())
            .navigationTitle("ترجمة الصور والنصوص")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    guard let newItem else { return }
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            self.selectedImage = uiImage
                            self.translatedOCRText = ""
                        }
                        await performOCR(on: uiImage)
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var photoPickerPlaceholderCard: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.vavaPrimary.opacity(0.1))
                        .frame(width: 80, height: 80)
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 38))
                        .foregroundStyle(Color.vavaPrimary)
                }

                VStack(spacing: 6) {
                    Text("اختر صورة للترجمة الفورية")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("حدد لافتة أو قائمة طعام أو مستنداً من ألبوم الصور، وسيتولى الذكاء الاصطناعي استخراج النص وترجمته فوراً.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                HStack(spacing: 6) {
                    Image(systemName: "photo.badge.plus")
                    Text("استيراد من المعرض")
                        .fontWeight(.bold)
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(LinearGradient.vavaHero)
                .clipShape(Capsule())
                .shadow(color: Color.vavaPrimary.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .background(Color.vavaCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    .foregroundStyle(Color.vavaBorder)
            )
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }

    private func imagePreviewCard(_ image: UIImage) -> some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                // Change Photo Button
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .padding(8)
                }
            }

            if isExtractingText {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("جار استخراج النصوص بدقة عبر Apple Vision...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
        }
        .padding(12)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal)
    }

    private var extractedTextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("النص المستخرج (OCR)", systemImage: "doc.text.viewfinder")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    UIPasteboard.general.string = extractedText
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                        .foregroundStyle(Color.vavaPrimary)
                }
            }

            Text(extractedText)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Translate button
            Button {
                translateExtractedText()
            } label: {
                HStack {
                    Image(systemName: "translate")
                    Text("ترجمة النص المستخرج")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.vavaPrimary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal)
    }

    private var translatedOutputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Text(appState.targetLanguage.flag)
                    Text("الترجمة (\(appState.targetLanguage.nativeName))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.vavaPrimary)
                }
                Spacer()
                if !translatedOCRText.isEmpty && !isTranslating {
                    Button {
                        playbackService.speak(text: translatedOCRText, languageCode: appState.targetLanguage.code)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.caption)
                            .foregroundStyle(Color.vavaPrimary)
                    }
                }
            }

            if isTranslating {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("جار ترجمة محتوى الصورة...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
            } else {
                Text(translatedOCRText.formattedForBidi)
                    .font(.body)
                    .fontWeight(.medium)
                    .alignForLanguage(appState.targetLanguage)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: appState.targetLanguage.isRTL ? .trailing : .leading)
            }
        }
        .padding(16)
        .background(Color.vavaPrimary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.vavaPrimary.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    // MARK: - Logic

    private func performOCR(on image: UIImage) async {
        isExtractingText = true
        let text = await visionService.recognizeText(from: image)
        await MainActor.run {
            self.extractedText = text
            self.isExtractingText = false
        }
    }

    private func translateExtractedText() {
        guard !extractedText.isEmpty else { return }
        isTranslating = true

        appState.requestTranslation(text: extractedText) { translated in
            self.translatedOCRText = translated
            self.isTranslating = false

            // Save to SwiftData
            let item = TranslationHistoryItem(
                sourceText: self.extractedText,
                translatedText: translated,
                sourceLanguageCode: "auto",
                targetLanguageCode: self.appState.targetLanguage.code,
                category: "camera"
            )
            self.modelContext.insert(item)
            try? self.modelContext.save()
        }
    }
}

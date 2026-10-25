import SwiftUI
import PhotosUI
import SwiftData

/// Complete production Camera & Photo OCR Translation view.
/// Supports both live camera capture and gallery photo imports.
public struct CameraOCRView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var appState: AppState

    @State private var cameraManager = LiveCameraManager.shared
    @State private var visionService = VisionOCRService.shared
    @State private var playbackService = AudioPlaybackService.shared

    @State private var isLiveCameraActive = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var activeImage: UIImage? = nil
    @State private var extractedText = ""
    @State private var translatedText = ""
    @State private var isTranslating = false

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vavaScreenBackground.ignoresSafeArea()

                if isLiveCameraActive {
                    liveCameraViewfinder
                } else {
                    galleryAndResultsScrollContent
                }
            }
            .navigationTitle("ترجمة الكاميرا والصور")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            isLiveCameraActive.toggle()
                            if isLiveCameraActive {
                                cameraManager.start()
                            } else {
                                cameraManager.stop()
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isLiveCameraActive ? "photo.fill" : "camera.fill")
                            Text(isLiveCameraActive ? "المعرض" : "الكاميرا الحية")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.vavaPrimary.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
            }
            .onChange(of: cameraManager.capturedImage) { _, newImage in
                if let newImage {
                    self.activeImage = newImage
                    self.isLiveCameraActive = false
                    cameraManager.stop()
                    Task { await processImage(newImage) }
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    guard let newItem else { return }
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            self.activeImage = image
                            self.translatedText = ""
                        }
                        await processImage(image)
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var liveCameraViewfinder: some View {
        ZStack {
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()

            // Viewfinder Guide Overlay
            VStack {
                // "Hold Steady" Guidance Banner
                HStack(spacing: 8) {
                    Image(systemName: "hand.raised.fill")
                        .foregroundStyle(Color.yellow)
                    Text("ثبّت الهاتف نحو النص المراد ترجمته")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.65))
                .clipShape(Capsule())
                .padding(.top, 16)

                Spacer()

                // Framing rectangle
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LinearGradient.vavaHero, lineWidth: 2)
                    .frame(height: 320)
                    .padding(.horizontal, 24)

                Spacer()

                // Shutter Capture Button
                HStack {
                    Spacer()
                    Button {
                        cameraManager.capturePhoto()
                        let impact = UIImpactFeedbackGenerator(style: .heavy)
                        impact.impactOccurred()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 76, height: 76)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 64, height: 64)
                        }
                    }
                    .padding(.bottom, 30)
                    Spacer()
                }
            }
        }
    }

    private var galleryAndResultsScrollContent: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Target Language Banner
                HStack {
                    Text("ترجمة النصوص إلى:")
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.vavaPrimary.opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(.horizontal)

                // Image Display / Import Card
                if let activeImage {
                    imageCard(activeImage)
                } else {
                    importPlaceholderCard
                }

                // Extracted OCR text card
                if !extractedText.isEmpty {
                    ocrResultCard
                }

                // Translated Card
                if !translatedText.isEmpty || isTranslating {
                    translatedCard
                }

                Spacer(minLength: 40)
            }
            .padding(.vertical)
        }
    }

    private var importPlaceholderCard: some View {
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
                Text("امسح النصوص أو استورد صورة")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("استخدم الكاميرا لمسح اللافتات والقوائم فوراً، أو اختر صورة من المعرض لاستخراج نصوصها.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            HStack(spacing: 14) {
                // Switch to Live Camera button
                Button {
                    withAnimation {
                        isLiveCameraActive = true
                        cameraManager.start()
                    }
                } label: {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("الكاميرا الحية")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.vavaPrimary)
                    .clipShape(Capsule())
                }

                // Gallery Picker
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("المعرض")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.vavaCardBackground)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.vavaBorder, lineWidth: 1))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(.horizontal)
    }

    private func imageCard(_ image: UIImage) -> some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button {
                    self.activeImage = nil
                    self.extractedText = ""
                    self.translatedText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .padding(8)
                }
            }

            if visionService.isProcessing {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("جار استخراج النصوص بدقة عبر Apple Vision...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(12)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal)
    }

    private var ocrResultCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("النص المقروء من الصورة", systemImage: "text.viewfinder")
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
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            Button {
                translateExtracted()
            } label: {
                HStack {
                    Image(systemName: "translate")
                    Text("ترجمة المحتوى الآن")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.vavaPrimary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .background(Color.vavaCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal)
    }

    private var translatedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("الترجمة (\(appState.targetLanguage.nativeName))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.vavaPrimary)
                Spacer()
                if !translatedText.isEmpty && !isTranslating {
                    Button {
                        playbackService.speak(text: translatedText, languageCode: appState.targetLanguage.code)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.caption)
                            .foregroundStyle(Color.vavaPrimary)
                    }
                }
            }

            if isTranslating {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("جار الترجمة العصبية...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 60)
            } else {
                Text(translatedText.formattedForBidi)
                    .font(.body)
                    .fontWeight(.semibold)
                    .alignForLanguage(appState.targetLanguage)
                    .frame(maxWidth: .infinity, alignment: appState.targetLanguage.isRTL ? .trailing : .leading)
            }
        }
        .padding(16)
        .background(Color.vavaPrimary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.vavaPrimary.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    // MARK: - Logic

    private func processImage(_ image: UIImage) async {
        let text = await visionService.recognizeText(from: image)
        await MainActor.run {
            self.extractedText = text
        }
    }

    private func translateExtracted() {
        guard !extractedText.isEmpty else { return }
        isTranslating = true
        appState.requestTranslation(text: extractedText) { translated in
            self.translatedText = translated
            self.isTranslating = false

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

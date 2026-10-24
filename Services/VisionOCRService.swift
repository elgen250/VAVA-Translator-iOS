import Foundation
import Vision
import UIKit
import Observation

/// OCR and Text Extraction Service using Apple Vision.framework.
/// Runs locally on device via the Apple Neural Engine.
@Observable
public final class VisionOCRService: @unchecked Sendable {
    public static let shared = VisionOCRService()

    public var isProcessing: Bool = false
    public var extractedText: String = ""
    public var recognizedBlocksCount: Int = 0
    public var errorMessage: String? = nil

    public init() {}

    /// Performs high-accuracy OCR on an input image.
    @MainActor
    public func recognizeText(from image: UIImage) async -> String {
        guard let cgImage = image.cgImage else {
            errorMessage = "صورة غير صالحة للتحليل البصري."
            return ""
        }

        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let self else {
                    continuation.resume(returning: "")
                    return
                }

                if let error {
                    Task { @MainActor in
                        self.errorMessage = error.localizedDescription
                        continuation.resume(returning: "")
                    }
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                    Task { @MainActor in
                        self.extractedText = ""
                        self.recognizedBlocksCount = 0
                        continuation.resume(returning: "")
                    }
                    return
                }

                // Extract top recognized text candidates
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                let fullText = recognizedStrings.joined(separator: "\n")
                Task { @MainActor in
                    self.extractedText = fullText
                    self.recognizedBlocksCount = observations.count
                    continuation.resume(returning: fullText)
                }
            }

            // Accurate recognition level with language correction
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    Task { @MainActor in
                        self.errorMessage = error.localizedDescription
                        continuation.resume(returning: "")
                    }
                }
            }
        }
    }
}

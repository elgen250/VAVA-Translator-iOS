import Foundation
import AVFoundation
import AVFAudio
import Observation

/// Text-to-Speech (TTS) audio playback service using AVFoundation's AVSpeechSynthesizer.
@Observable
public final class AudioPlaybackService: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    public static let shared = AudioPlaybackService()

    public var isSpeaking: Bool = false
    public var currentSpeakingText: String? = nil

    private let synthesizer = AVSpeechSynthesizer()

    public override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Speaks the given text using the appropriate localized voice.
    @MainActor
    public func speak(text: String, languageCode: String) {
        stop()
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Configure audio session for playback
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("AudioSession configuration error: \(error)")
        }

        let utterance = AVSpeechUtterance(string: text)
        
        // Find best matching voice for language code
        let bcp47 = bcp47Code(from: languageCode)
        if let voice = AVSpeechSynthesisVoice(language: bcp47) {
            utterance.voice = voice
        } else if let fallback = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = fallback
        }

        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95 // Slightly natural pacing
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        currentSpeakingText = text
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Stops any ongoing audio speech playback immediately.
    @MainActor
    public func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        currentSpeakingText = nil
    }

    // MARK: - AVSpeechSynthesizerDelegate

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentSpeakingText = nil
        }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentSpeakingText = nil
        }
    }

    // MARK: - Helpers

    private func bcp47Code(from code: String) -> String {
        switch code.lowercased() {
        case "ar": return "ar-SA"
        case "en": return "en-US"
        case "es": return "es-ES"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "it": return "it-IT"
        case "pt-br", "pt": return "pt-BR"
        case "ru": return "ru-RU"
        case "zh-hans", "zh": return "zh-CN"
        case "zh-hant": return "zh-TW"
        case "ja": return "ja-JP"
        case "ko": return "ko-KR"
        case "tr": return "tr-TR"
        default: return code
        }
    }
}

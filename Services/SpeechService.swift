import Foundation
import Speech
import AVFoundation
import Observation

/// Speech-to-Text (STT) service using Apple Speech.framework.
/// Configured for on-device recognition when available for instant offline transcription.
@Observable
public final class SpeechService: NSObject, @unchecked Sendable {
    public static let shared = SpeechService()

    public var isRecording: Bool = false
    public var transcriptText: String = ""
    public var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    public var errorMessage: String? = nil

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    public override init() {
        super.init()
        requestAuthorization()
    }

    /// Requests user authorization for speech recognition.
    public func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                self?.authorizationStatus = status
            }
        }
    }

    /// Starts recording and transcribing speech in the specified language.
    @MainActor
    public func startRecording(language: SupportedLanguage) throws {
        // Cancel any active tasks
        stopRecording()
        errorMessage = nil

        let locale = Locale(identifier: language.code == "auto" ? "ar-SA" : language.code)
        speechRecognizer = SFSpeechRecognizer(locale: locale)

        guard let speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "محرك التعرف الصوتي غير متاح حالياً لهذه اللغة."
            return
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            errorMessage = "تعذر إنشاء طلب التعرف الصوتي."
            return
        }

        // Configure on-device recognition if available
        if speechRecognizer.supportsOnDeviceRecognition {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
        transcriptText = ""

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    self.transcriptText = result.bestTranscription.formattedString
                }
                if error != nil || (result?.isFinal ?? false) {
                    self.stopRecording()
                }
            }
        }
    }

    /// Stops recording and finalizes transcription.
    @MainActor
    public func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}

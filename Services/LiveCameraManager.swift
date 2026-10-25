import Foundation
import AVFoundation
import UIKit
import Observation

/// Real-time AVCaptureSession camera manager for live viewfinder OCR translation.
@Observable
public final class LiveCameraManager: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    public static let shared = LiveCameraManager()

    public var isSessionRunning: Bool = false
    public var isCameraAuthorized: Bool = false
    public var capturedImage: UIImage? = nil
    public var isCapturingPhoto: Bool = false

    public let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.vava.camera.sessionQueue")

    public override init() {
        super.init()
        checkPermissions()
    }

    public func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isCameraAuthorized = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    self?.isCameraAuthorized = granted
                    if granted { self?.setupSession() }
                }
            }
        default:
            self.isCameraAuthorized = false
        }
    }

    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            // Configure wide-angle back camera
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                return
            }
            self.session.addInput(input)

            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }

            self.session.commitConfiguration()
            self.session.startRunning()

            Task { @MainActor in
                self.isSessionRunning = self.session.isRunning
            }
        }
    }

    public func start() {
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
            Task { @MainActor in
                self.isSessionRunning = true
            }
        }
    }

    public func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
            Task { @MainActor in
                self.isSessionRunning = false
            }
        }
    }

    public func capturePhoto() {
        guard session.isRunning else { return }
        isCapturingPhoto = true
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - AVCapturePhotoCaptureDelegate

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        Task { @MainActor in
            self.isCapturingPhoto = false
            guard error == nil,
                  let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else {
                return
            }
            self.capturedImage = image
        }
    }
}

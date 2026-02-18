//
//  CameraManager.swift
//  Tool-Caddy
//
//  Created by Sohum Mogale on 9/2/2026.
// Manages AVCaptureSession:
// Configures camera
// Starts/Stops session
// Captures a still image
//
import Combine
import AVFoundation
import UIKit

final class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    var onPhotoCaptured: ((UIImage) -> Void)?
    
    override init() {
        super.init()
        configureSession()
    }
    
    private func configureSession() {
        session.beginConfiguration()
        
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video,
                                                 position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }
        
        session.addInput(input)
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData)
        else {
            return
        }
        
        onPhotoCaptured?(uiImage)
    }
}

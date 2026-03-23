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
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override init() {
        super.init()
        configureSession()
    }
    
    private func configureSession() {
        sessionQueue.async{
            self.session.beginConfiguration()
            
            defer{
                self.session.commitConfiguration()
                self.startSession()
                
            }
            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                     for: .video,
                                                     position: .back),
                let input = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else {
                return
            }
            
            self.session.addInput(input)
            
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }
            
        }
    }
    
    func startSession() {
        sessionQueue.async{
            guard !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
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

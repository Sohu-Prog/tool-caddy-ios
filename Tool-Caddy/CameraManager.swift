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
import Vision
import CoreML

final class CameraManager: NSObject, ObservableObject {
    @Published var predictionLabel: String = ""
    
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    var onPhotoCaptured: ((UIImage) -> Void)?
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var visionModel: VNCoreMLModel?
    
    
    
    override init() {
        super.init()
        do {
            let mlModel = try MobileNetV3Classifier()
            visionModel = try VNCoreMLModel(for: mlModel.model)
        } catch {
            print("Model failed to load: \(error)")
        }
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
        
        classifyImage(uiImage)
        onPhotoCaptured?(uiImage)

        
    }
    
    private func classifyImage(_ image: UIImage) {
        guard let cgImage = image.cgImage,
                let visionModel = visionModel
        else {return}
        
        let request = VNCoreMLRequest(model: visionModel) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
            else {return}
            
            DispatchQueue.main.async {
                self?.predictionLabel = topResult.identifier
    //            self.confidence = Double(topResult.confidence)
    // To add confidence need to have softmax layer
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])

    }
    
    
}


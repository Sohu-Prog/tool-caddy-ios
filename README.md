# Golf Lie Identifier (iOS)

iOS application that identifies the lie of a golf ball (how the ball sits), and gives curated advice depending on the condition..

## Tech Stack
- Swift / SwiftUI
- AVFoundation
- Vision
- Core ML
- MobileNet V3

## Current Status
**Development**
See `PROGRESS.md` for weekly updates.


## Architecture Overview:

<img width="1255" height="538" alt="image" src="https://github.com/user-attachments/assets/e5e2c570-ca68-4b4e-af28-0128d0aeaf26" />

### 1. [ iOS Camera Capture ]
 - Use AVFoundation functions within the CameraManager class ; AVCaptureSession, AVCapturePhotoOutput using the default AVCaptureDevice/config.
          
### 2. [ Image Preprocessing ]
  - Pass Binary photoData into Model, 224x224pixels
  - Normalisation baked into model
    

### 3. [ CoreML Model (MobileNetV3) ]
  - Exported from PyTorch → CoreML (.mlmodel) -> VNCoreMLModel
  - Model tuned via transfer learning on custom curated dataset. 
    
### 4. [ Inference via Vision Framework ]
  - VNCoreMLRequest performs real-time classification
  - Returns probabilities for each lie type
          │
          ▼
### 5. [ Advice Engine / Decision Logic ]
  - Maps predicted lie type + environment features → shot recommendations
  - Can incorporate rule-based adjustments in acordance to factors identified (e.g., slope, grass type)
          │
          ▼
### 6. [ UI Display / SwiftUI Overlay ]
  - Shows predicted lie type
  - Displays recommended shot strategy
  - Updates dynamically with camera input

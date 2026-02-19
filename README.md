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
###[ iOS Camera Capture ]
          │
          ▼
### [ Image Preprocessing ]
  - Resize to model input (e.g., 256x256)
  - Normalize pixel values (same as training)
  - Optionally crop around detected ball region
          │
          ▼
### [ CoreML Model (MobileNetV3) ]
  - Exported from PyTorch → ONNX → CoreML (.mlmodel)
  - Fine-tuned on golf lie dataset
  - Performs image classification
          │
          ▼
### [ Inference via Vision Framework ]
  - VNCoreMLRequest performs real-time classification
  - Returns probabilities for each lie type
          │
          ▼
### [ Advice Engine / Decision Logic ]
  - Maps predicted lie type + environment features → shot recommendations
  - Can incorporate rule-based adjustments (e.g., slope, grass type)
          │
          ▼
### [ UI Display / SwiftUI Overlay ]
  - Shows predicted lie type
  - Displays recommended shot strategy
  - Updates dynamically with camera input

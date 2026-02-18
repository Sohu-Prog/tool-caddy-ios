//
//  CameraView.swift
//  Tool-Caddy
//
//  Created by Sohum Mogale on 9/2/2026.
//  Camera Preview Screen


import SwiftUI

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage?
    @State private var buttonPressed: Bool = false
    
    var body: some View {
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        
        ZStack {
            
            if(isPreview) {
               previewPlaceholder
            } else {
                CameraPreview(session: cameraManager.session).ignoresSafeArea()
            }
            
               
            
            VStack {
                Spacer()
                
                Button(action: {
                    if !isPreview {
                        cameraManager.capturePhoto()
                    }
                    buttonPressed = true
                }) {
                    Circle().fill(Color.blue)
                        .frame(width: 70, height: 70)
                        .overlay(Circle().stroke(Color.black, lineWidth:2))
                }
                .padding(.bottom, 30)
                
                if (isPreview && buttonPressed) {
                    Text("Feature not available in Preview").font(Font.largeTitle.bold()).foregroundColor(.blue).zIndex(3)
                }
            }
        }
        .onAppear {
            if !isPreview {
                cameraManager.onPhotoCaptured = { image in
                    capturedImage = image
                    // ML code
                }
                cameraManager.startSession()
            }
        }
        .onDisappear {
            if !isPreview {
                cameraManager.stopSession()
            }
        }
    }
    
    var previewPlaceholder: some View {
        Color.gray
        .overlay(Text("Camera Preview Placeholder"))
        .foregroundColor(Color.white)
    }
    
    
}

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
    
    
    var body: some View {
        ZStack {
            #if targetEnvironment(simulator)
            Color.gray
            #else
            
                CameraPreview(session: cameraManager.session).ignoresSafeArea()
            #endif
            
            VStack {
                Spacer()
                
                Button(action: {
                    cameraManager.capturePhoto()
                }) {
                    Circle().fill(Color.blue)
                        .frame(width: 70, height: 70)
                        .overlay(Circle().stroke(Color.black, lineWidth:2))
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            #if !targetEnvironment(simulator)
            cameraManager.onPhotoCaptured = { image in
                capturedImage = image
                // ML code
            }
            cameraManager.startSession()
            #endif
        }
        .onDisappear {
            #if !targetEnvironment(simulator)
            cameraManager.stopSession()
            #endif
        }
    }
    
    
    
}
